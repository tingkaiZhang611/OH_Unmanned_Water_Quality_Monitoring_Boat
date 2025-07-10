import http from '@ohos.net.http';

export class PostUtil{
  // POST请求的URL和数据
  private Token: string = "nullToken";
  private getTokenUrl:string="https://iam.cn-north-4.myhuaweicloud.com/v3/auth/tokens";
  private upperUrl:string="https://c899f8ccbf.st1.iotda-app.cn-north-4.myhuaweicloud.com/v5/iot/0db7c4da63a84d75a2f274ce39252e4d/devices/866597071510554/messages";
  public CodeAndBackMessage:string="";

  constructor() {
    this.postGetToken();
  }

  // 获取Token
  async postGetToken() {

    const getTokenBodyJSON = `{
    "auth": {
        "identity": {
            "methods": [
                "password"
            ],
            "password": {
                "user": {
                    "name": "yj",
                    "password": "yj123456",
                    "domain": {
                        "name": "yyj12345678_"
                    }
                }
            }
        },
        "scope": {
            "project": {
                "name": "cn-north-4"
            }
        }
    }
}`;

    let httpRequest = http.createHttp();
    try {
      let response = await httpRequest.request(
        this.getTokenUrl,
        {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json' },
          extraData: getTokenBodyJSON // POST请求体数据
        }
      );

      if (response.responseCode >= 200 && response.responseCode < 300) {
        this.Token=response.header["x-subject-token"];
      }else{
        this.Token = `请求失败!\n状态码: ${response.responseCode}`;
      }
    } catch (err) {
      this.Token = `网络错误: ${JSON.stringify(err)}`;
    } finally {
      httpRequest.destroy();
    }
  }


  // POST上报
  async postUpper(message:string) {

    let httpRequest = http.createHttp();
    let questBody = '{"message":"'+message+'"}';
    try {
      let response = await httpRequest.request(
        this.upperUrl,
        {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json' ,'X-Auth-Token':this.Token},
          extraData: questBody // POST请求体数据
        }
      );

      if (response.responseCode >= 200 && response.responseCode < 300) {
        this.CodeAndBackMessage = `POST成功!\n状态码: ${response.responseCode}\n响应数据: ${response.result}`;
      } else {
        this.CodeAndBackMessage = `请求失败!\n状态码: ${response.responseCode}`;
      }
    } catch (err) {
      this.CodeAndBackMessage = `网络错误: ${JSON.stringify(err)}`;
    } finally {
      httpRequest.destroy();
    }
  }



  public getToken():string{
    return this.Token;
  }
}