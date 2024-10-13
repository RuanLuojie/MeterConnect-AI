using ThreeDFamilyApi.Model;
using Microsoft.AspNetCore.Mvc;
using System.Drawing;
using System.Diagnostics.CodeAnalysis;

namespace ThreeDfamily.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [SuppressMessage("Interoperability", "CA1416:驗證平台相容性")]
    public class ThreeDfamilyController : ControllerBase
    {
        private readonly ILogger<ThreeDfamilyController> _logger;

        /// <summary> 智泰分類伺服器AI </summary>
        private readonly string _AIServerIP;

        /// <summary> 等比裁切數量 </summary>
        private readonly int _CutNum;

        public ThreeDfamilyController(
            ILogger<ThreeDfamilyController> logger,
            IConfiguration configuration)
        {
            _logger = logger;
            _AIServerIP = configuration["ThreeDFamilyApiSettings"]!;
            _CutNum = Convert.ToInt32(configuration["CutNum"]);
        }

        /// <summary> 智泰電表AI推理Api </summary>
        /// <param name="file">傳進來的檔案</param>
        /// <returns>推理後的數據</returns>
        [HttpPost("ThreeDfamilyApi")]
        //[ValidateAntiForgeryToken] //在測試的時候會擋住postMan及python程式發送的檔案，不確定正式會不會
        async public Task<AIReasoningPostReturn> ThreeDfamilyApi(IFormFile? file)
        {
            AIReasoningPostReturn postOut = new(); //最終回傳的數據
            try
            {
                string clientIp = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "無法取得IP";

                _logger.LogInformation("ThreeDfamilyApi被調用，使用者IP:" + clientIp);

                if (file == null || file.Length == 0) 
                {
                    postOut.SetErrorState("並未上傳檔案");
                    return postOut;
                }

                //使用資料流處理圖片
                using MemoryStream stream = new();
                await file.CopyToAsync(stream);
                stream.Seek(0, SeekOrigin.Begin);

                using Image image = Image.FromStream(stream, true, true); //若傳進來的數據不是圖片會報錯

                //int cutCount = 1;

                ///將圖片等比裁切並送至智泰伺服器，拼湊出答案後回傳
                foreach (Bitmap img in ThreeDFamilyFuc.CutImageIterator(image, _CutNum))
                {
                    (string resultClass, double resultScore) = await ThreeDFamilyFuc.PostToThreeDFamilyAI(img, _AIServerIP);
                    postOut.AddResultData(resultClass, resultScore);

                    //string filePath = @$"C:\Users\peter\Downloads\myImage{cutCount}.png";
                    //img.Save(filePath, ImageFormat.Png);
                    //cutCount ++;
                }

                byte[] imgByte = ThreeDFamilyFuc.GetImageByte(image); //日後資料庫儲存使用
                return postOut;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"推理失敗，失敗原因:{ex.Message}");
                postOut.SetErrorState(ex.Message);
                return postOut;
            }
        }
    }
}
