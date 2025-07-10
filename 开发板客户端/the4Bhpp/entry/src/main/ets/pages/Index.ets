
import testNapi from 'libentry.so';

const DOMAIN = 0x0000;


interface Order{
  name:string;
  id:string;
  content:string
}

@Entry
@Component
struct Index {
  //左电机控制
  @State message: string = '左正';
  @State message2: string = '左关';
  @State message3: string = '左倒';
  //右电机控制
  @State message4: string = '右正';
  @State message5: string = '右关';
  @State message6: string = '右倒';
  //
  @State onnou:number=0.0;
  @State testmessage:string="";
  @State message7: string = '前进';
  @State message8: string = '后退';
  @State message9: string = '停止';
  @State Iot:string="null";
  build() {
    Row() {
      Column(){
        Text(String(this.onnou))
          .fontSize(24)
        Text("串口：~"+String(this.testmessage))
          .fontSize(24)
        Text("IoT接收："+String(this.Iot))
          .fontSize(24)
      }
      Column(){
        Button(this.message7)
          .fontSize($r('app.float.page_text_font_size'))
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.message7 = this.message7+testNapi.left(1,1);
            this.message7 = this.message7+testNapi.right(1,1);
          })
        Button(this.message8)
          .fontSize($r('app.float.page_text_font_size'))
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.message8 = this.message8+testNapi.left(1,0);
            this.message8 = this.message8+testNapi.right(1,0);
          })
        Button(this.message9)
          .fontSize($r('app.float.page_text_font_size'))
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.message9 = this.message9+testNapi.left(0,0);
            this.message9 = this.message9+testNapi.right(0,0);
          })
        Button('原神启动')
          .fontSize($r('app.float.page_text_font_size'))
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            const fd=testNapi.open("/dev/ttyS0",9600);
            this.testmessage="串口已经开启";


            let intervalId = setInterval(() => {
              let getMessage = testNapi.read();
              let paimeng = this.deASCII(getMessage);
              if (this.Iot != 'null') {
                this.Iot = paimeng;
              }

              try {
                let start=paimeng.lastIndexOf("[ORDER]");
                if (start != -1) {
                  //符合ORDER
                  let end=paimeng.indexOf('"',start+7)
                  let order=paimeng.substring(start+7,end);
                  switch (order) {
                    case 'right': {
                      this.Iot = "right";
                      //电机方向逻辑

                      this.message9 = this.message9 + testNapi.left(0, 0);
                      this.message9 = this.message9 + testNapi.right(0, 0);


                      this.message = this.message + testNapi.left(1, 0);
                      break;
                    }
                    case 'left': {
                      this.Iot = "left";
                      //电机方向逻辑

                      this.message9 = this.message9 + testNapi.left(0, 0);
                      this.message9 = this.message9 + testNapi.right(0, 0);

                      this.message4 = this.message4 + testNapi.right(1, 0);
                      break;
                    }
                    case 'centen': {
                      this.Iot = "centen";
                      //电机方向逻辑
                      this.message9 = this.message9 + testNapi.left(0, 0);
                      this.message9 = this.message9 + testNapi.right(0, 0);
                      break;
                    }
                    case 'up': {
                      this.Iot = "up";
                      //电机方向逻辑

                      this.message9 = this.message9 + testNapi.left(0, 0);
                      this.message9 = this.message9 + testNapi.right(0, 0);

                      this.message7 = this.message7 + testNapi.left(1, 0);
                      this.message7 = this.message7 + testNapi.right(1, 0);
                      break;
                    }
                    case 'under': {
                      this.Iot = "under";
                      //电机方向逻辑


                      this.message9 = this.message9 + testNapi.left(0, 0);
                      this.message9 = this.message9 + testNapi.right(0, 0);

                      this.message8 = this.message8 + testNapi.left(1, 1);
                      this.message8 = this.message8 + testNapi.right(1, 1);
                      break;
                    }
                    default: {
                      //小丑~
                      this.Iot = "未知";
                      ;
                    }
                  }
                } else {
                }
              }catch (e) {
                testNapi.left(0,0);
                testNapi.right(0,0);
              }


              // "hj".lastIndexOf()
              // let getMessage=testNapi.read();
              // this.testmessage="结果："+this.deASCII(getMessage);

              // },100)
            }, 100);

          })
      }
      //-------------------------------------------------------------------------------------------
      Column() {
        Button(this.message)
          .fontSize($r('app.float.page_text_font_size'))
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.message = this.message+testNapi.left(1,0);
          })
        Button(this.message3)
          .fontSize($r('app.float.page_text_font_size'))
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.message3 = this.message3+testNapi.left(1,1);
          })
        Button(this.message2)
          .fontSize($r('app.float.page_text_font_size'))
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.message2 = this.message2+testNapi.left(0,0);
          })
        //.............................................................................................................
        Button(this.message4)
          .fontSize($r('app.float.page_text_font_size'))
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.message4 = this.message4+testNapi.right(1,0);
          })
        Button(this.message5)
          .fontSize($r('app.float.page_text_font_size'))
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.message5 = this.message5+testNapi.right(0,0);
          })
        Button(this.message6)
          .fontSize($r('app.float.page_text_font_size'))
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.message6 = this.message6+testNapi.right(1,1);
          })


        Button('test温度')
          .fontSize($r('app.float.page_text_font_size'))
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.onnou = testNapi.getOnnDou(0,0);
          })


        Button('打开串口')
          .fontSize($r('app.float.page_text_font_size'))
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            const fd=testNapi.open("/dev/ttyS0",9600);
            this.testmessage="串口已经开启";
          })

        Button('send消息')
          .fontSize($r('app.float.page_text_font_size'))
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            let baga=testNapi.write("二逼黄pp");
            this.testmessage="已发送字节："+baga;
          })

        Button('接受消息')
          .fontSize($r('app.float.page_text_font_size'))
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            let getMessage=testNapi.read();
            this.testmessage="结果："+this.deASCII(getMessage);
          })

        Button('关闭串口')
          .fontSize($r('app.float.page_text_font_size'))
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            const a=testNapi.close();
            this.testmessage="串口已关闭";
          })
      }
      .width('100%')
    }
    .height('100%')
  }

  deASCII(arr: Array<number>): string {

    if(arr===undefined){
      return "null";
    }

    //块处理（避免栈溢出）
    const CHUNK_SIZE = 10000; // 安全阈值
    let result = "";
    for (let i = 0; i < arr.length; i += CHUNK_SIZE) {
      const chunk = arr.slice(i, i + CHUNK_SIZE);
      result += String.fromCharCode(...chunk);
    }
    return result;
  }
}
