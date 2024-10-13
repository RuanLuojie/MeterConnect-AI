using ThreeDFamilyApi.Model;
using Microsoft.AspNetCore.Mvc;
using System.Drawing;
using System.Diagnostics.CodeAnalysis;

namespace ThreeDfamily.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [SuppressMessage("Interoperability", "CA1416:���ҥ��x�ۮe��")]
    public class ThreeDfamilyController : ControllerBase
    {
        private readonly ILogger<ThreeDfamilyController> _logger;

        /// <summary> �����������A��AI </summary>
        private readonly string _AIServerIP;

        /// <summary> ��������ƶq </summary>
        private readonly int _CutNum;

        public ThreeDfamilyController(
            ILogger<ThreeDfamilyController> logger,
            IConfiguration configuration)
        {
            _logger = logger;
            _AIServerIP = configuration["ThreeDFamilyApiSettings"]!;
            _CutNum = Convert.ToInt32(configuration["CutNum"]);
        }

        /// <summary> �����q��AI���zApi </summary>
        /// <param name="file">�Ƕi�Ӫ��ɮ�</param>
        /// <returns>���z�᪺�ƾ�</returns>
        [HttpPost("ThreeDfamilyApi")]
        //[ValidateAntiForgeryToken] //�b���ժ��ɭԷ|�צ�postMan��python�{���o�e���ɮסA���T�w�����|���|
        async public Task<AIReasoningPostReturn> ThreeDfamilyApi(IFormFile? file)
        {
            AIReasoningPostReturn postOut = new(); //�̲צ^�Ǫ��ƾ�
            try
            {
                string clientIp = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "�L�k���oIP";

                _logger.LogInformation("ThreeDfamilyApi�Q�եΡA�ϥΪ�IP:" + clientIp);

                if (file == null || file.Length == 0) 
                {
                    postOut.SetErrorState("�å��W���ɮ�");
                    return postOut;
                }

                //�ϥθ�Ƭy�B�z�Ϥ�
                using MemoryStream stream = new();
                await file.CopyToAsync(stream);
                stream.Seek(0, SeekOrigin.Begin);

                using Image image = Image.FromStream(stream, true, true); //�Y�Ƕi�Ӫ��ƾڤ��O�Ϥ��|����

                //int cutCount = 1;

                ///�N�Ϥ���������ðe�ܴ������A���A����X���׫�^��
                foreach (Bitmap img in ThreeDFamilyFuc.CutImageIterator(image, _CutNum))
                {
                    (string resultClass, double resultScore) = await ThreeDFamilyFuc.PostToThreeDFamilyAI(img, _AIServerIP);
                    postOut.AddResultData(resultClass, resultScore);

                    //string filePath = @$"C:\Users\peter\Downloads\myImage{cutCount}.png";
                    //img.Save(filePath, ImageFormat.Png);
                    //cutCount ++;
                }

                byte[] imgByte = ThreeDFamilyFuc.GetImageByte(image); //����Ʈw�x�s�ϥ�
                return postOut;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"���z���ѡA���ѭ�]:{ex.Message}");
                postOut.SetErrorState(ex.Message);
                return postOut;
            }
        }
    }
}
