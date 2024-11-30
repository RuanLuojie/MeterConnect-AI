using System.Text;
using System.Net.Http.Headers;
using System.Text.Json;
using System;
using System.Security.AccessControl;
namespace MeterConnectAIWeb.Models
{
    public class MeterRecord
    {
        public string meter_type { get; set; }

        public string file_guid { get; set; }

        public DateTime captured_time { get; set; }

        public string recognized_text { get; set; }
    }

    public class FlyIoSqlService
    {
        private readonly HttpClient _httpClient;

        public FlyIoSqlService(HttpClient httpClient)
        { 
            _httpClient = httpClient;
        }

        async public Task<List<MeterRecord>> GetMeterRecord(string apiKey) 
        {
            var request = new HttpRequestMessage(HttpMethod.Get, "api/SqlApi/PhotoRecords");

            request.Headers.Add("X-API-KEY", apiKey);
            
            var response = await _httpClient.SendAsync(request);

            response.EnsureSuccessStatusCode();

            List<MeterRecord>? meterRecords =  
                JsonSerializer.Deserialize<List<MeterRecord>>(
                    await response.Content.ReadAsStringAsync()
                );

            return meterRecords;
        }
    }
}
