using Newtonsoft.Json.Linq;
using System.Diagnostics.CodeAnalysis;
using System.Drawing;
using System.Net.Http.Headers;
using System.Drawing.Imaging;
using System.IO;
using Microsoft.AspNetCore.Mvc;
namespace ThreeDFamilyApi.Model
{
    [SuppressMessage("Interoperability", "CA1416:驗證平台相容性")]
    public class ThreeDFamilyFuc
    {
        /// <summary> Base64圖片水平等比裁切迭代器 </summary>
        /// <param name="image">裁切的圖片</param>
        /// <param name="cutNum">裁切數量</param>
        /// <returns>裁切後的照片</returns>
        public static IEnumerable<Bitmap> CutImageIterator(Image image, int cutNum)
        {
            for (int cutCount = 0; cutCount < cutNum; cutCount++)
            {
                int cropImageWidth = image.Width / cutNum; //等比寬度
                int cropImageX = cropImageWidth * cutCount; //每一張裁切圖片的起始X

                Rectangle cropRect = new(
                    cropImageX,
                    0, 
                    cropImageWidth, 
                    image.Height
                );

                using Bitmap croppedImage = new(cropRect.Width, cropRect.Height);
                using Graphics g = Graphics.FromImage(croppedImage);

                g.DrawImage(
                    image,
                    new Rectangle(0, 0, croppedImage.Width, croppedImage.Height),
                    cropRect,
                    GraphicsUnit.Pixel
                );

                yield return croppedImage;
            }
        }

        /// <summary> 將圖片轉為Byte </summary>
        /// <param name="image">圖片</param>
        /// <returns>圖片檔的Byte</returns>
        /// <remarks>日後SQL儲存用</remarks>
        public static byte[] GetImageByte(Image image)
        {
            using var stream = new MemoryStream();
            image.Save(stream, ImageFormat.Jpeg); // 你可以根据需要选择其他格式
            return stream.ToArray();
        }

        /// <summary> 將圖片發送至智泰科技的AI辨識伺服器 </summary>
        /// <param name="img">圖片</param>
        /// <param name="serverIp">智泰科技的AI辨識伺服器IP位置</param>
        /// <returns>最高信心指數的辨識結果，Item1為辨識類別，Item2為信心指數</returns>
        async public static Task<Tuple<string, double>> PostToThreeDFamilyAI(Bitmap img, string serverIp)
        {
            //將圖片寫入記憶體
            using MemoryStream memoryStream = new();
            await Task.Run(() => img.Save(memoryStream, ImageFormat.Png));
            memoryStream.Seek(0, SeekOrigin.Begin);

            //與智泰AI伺服器通訊用到的物件
            using HttpClient httpClient = new();
            using MultipartFormDataContent content = [];
            StreamContent fileContent = new(memoryStream);

            fileContent.Headers.ContentDisposition = new ContentDispositionHeaderValue("form-data")
            {
                Name = "media",
                FileName = "image.png"
            };

            content.Add(fileContent);

            using var response = await httpClient.PostAsync(serverIp, content);
            var responseContent = await response.Content.ReadAsStringAsync();

            JObject json = JObject.Parse(responseContent);
            string resultClass = json["Message"]["predictions"][0]["classIndex"].ToString();
            double resultScore = (Math.Round((double)json["Message"]["predictions"][0]["score"], 2));

            return new Tuple<string, double>(resultClass, resultScore);
        }
    }
}
