
namespace ThreeDFamilyApi.Model
{
    /// <summary> Api最終回傳格式 </summary>
    public partial class AIReasoningPostReturn
    {
        /// <summary> 切割後AI推理信心指數 </summary>
        public List<double> ResultScoreList { get; set; } = [];

        /// <summary> AI對整個圖片切割後的所有答案 </summary>
        public string Result { get; set; } = "";

        /// <summary> 是否成功推理 </summary>
        public bool IsSuccess { get; set; } = true;

        /// <summary> 推理失敗的錯誤訊息，推理成功則為空字串 </summary>
        public string ErrorMessge { get; set; } = "";

        public AIReasoningPostReturn()
        {
            
        }

        /// <summary> 將智泰科技辨識結果儲存至此物件 </summary>
        /// <param name="result">辨識結果</param>
        /// <remarks>Tuple的Item1為辨識類別，Item2為信心指數</remarks>
        public void AddResultData(string resultClass, double resultScore)
        {
            Result += resultClass;
            ResultScoreList.Add(resultScore);
        }

        /// <summary> 將物件設置為錯誤狀態 </summary>
        /// <param name="errorMessge"> 錯誤訊息 </param>
        public void SetErrorState(string errorMessge) 
        {
            ResultScoreList = [];
            Result = "";
            IsSuccess = false;
            ErrorMessge = errorMessge;
        }
    }
}
