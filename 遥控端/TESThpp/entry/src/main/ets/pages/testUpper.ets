import {PostUtil} from '../Component/Web';
@Component
export struct testUpper{
  @State backMessage:string="Loading Message。。。";
  @State inputs:string="";
  poster:PostUtil=new PostUtil();
  build() {
    RelativeContainer(){
      Column(){
        Text(this.backMessage)
          .fontSize(24)

        TextInput()
          .fontSize(24)
          .onChange((value)=>{
            this.inputs=value;
          })
        Button("Token初始化")
          .onClick(()=>{
            // this.poster.postUpper("[ORDER]终于完成了POS!");
            // this.backMessage=this.poster.CodeAndBackMessage+1;
            this.poster.postGetToken();
          })

        Button("获取Token")
          .onClick(()=>{
            this.backMessage=this.poster.getToken();
          })

        Button("下发消息到设备")
          .onClick(()=>{
            this.poster.postUpper(this.inputs);
            this.backMessage=this.poster.CodeAndBackMessage;
          })
      }
    }
  }
}