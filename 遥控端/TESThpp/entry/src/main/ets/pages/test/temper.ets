import { hmChart, ChartOptions, hmChartType } from "@wuyan/hm_chart";

// ====================== 核心类型定义（与库严格对齐） ======================
interface ChartAxisLineStyle {
  color: string;
}

interface ChartAxisLabel {
  color: string;
  formatter?: string;
}

interface ChartTextStyle {
  color?: string;
  fontStyle?: 'normal' | 'italic' | 'oblique';
  fontWeight?: string | number;
  fontFamily?: string;
  fontSize?: number;
  lineHeight?: number;
  textBorderColor?: string;
  textBorderWidth?: number;
  textShadowColor?: string;
  textShadowBlur?: number;
  textShadowOffsetX?: number;
  textShadowOffsetY?: number;
}

interface ChartAxisLine {
  lineStyle: ChartAxisLineStyle;
}

interface ChartXAxis {
  type: 'category';
  data: string[];
  axisLine?: ChartAxisLine;
  axisLabel?: ChartAxisLabel;
}

interface ChartYAxis {
  type: 'value';
  min: number;
  max: number;
  splitLine?: ChartAxisLine;
  axisLabel?: ChartAxisLabel;
}

interface ChartGrid {
  left: string;
  right: string;
  bottom: string;
  top: string;
  containLabel: boolean;
}

interface ChartLineStyle {
  width: number;
  color: string;
}

interface ChartItemStyle {
  color: string;
  borderWidth: number;
  borderColor: string;
}

interface ChartColorStop {
  offset: number;
  color: string;
}

interface ChartAreaStyleColor {
  type: 'linear';
  x: number;
  y: number;
  x2: number;
  y2: number;
  colorStops: ChartColorStop[];
}

interface ChartAreaStyle {
  color: ChartAreaStyleColor;
}

// 修改：让 symbol 和 symbolSize 变为可选属性
interface ChartSeries {
  name: string;
  type: 'line';
  data: number[];
  smooth: boolean;
  symbol?: 'circle';        // 改为可选
  symbolSize?: number;      // 改为可选
  lineStyle: ChartLineStyle;
  itemStyle: ChartItemStyle;
  areaStyle: ChartAreaStyle;
}

interface ChartTooltipParam {
  axisValue: string;
  data: number;
}

interface ChartTooltip {
  trigger: 'axis';
  backgroundColor: string;
  borderColor: string;
  borderWidth: number;
  padding: number;
  textStyle: ChartTextStyle;
  formatter: (params: ChartTooltipParam[]) => string;
}

// ====================== 主组件实现 ======================
@Entry
@Component
struct TemperatureMonitor {
  @State myChart: hmChartType | null = null;
  @State temperatures: number[] = [];
  @State timeLabels: string[] = [];
  @State currentTemp: number = 0;
  @State lastTemp: number = 25; // 新增：记录上一个温度值，控制波动范围

  private chartOptions: ChartOptions = {
    xAxis: {
      type: 'category',
      data: [],
      axisLine: { lineStyle: { color: '#888' } },
      axisLabel: { color: '#666' }
    },
    yAxis: {
      type: 'value',
      min: 10,
      max: 40,
      splitLine: { lineStyle: { color: '#f0f0f0' } },
      axisLabel: { formatter: '{value}°C', color: '#666' }
    },
    grid: {
      left: '5%',
      right: '5%',
      bottom: '10%',
      top: '15%',
      containLabel: true
    },
    series: [
      {
        name: '温度',
        type: 'line',
        data: [],
        smooth: true,
        symbol: 'circle',  // 实际存在，可选属性不影响类型匹配
        symbolSize: 8,     // 实际存在，可选属性不影响类型匹配
        lineStyle: { width: 3, color: '#36a1ff' },
        itemStyle: { color: '#ffffff', borderWidth: 2, borderColor: '#36a1ff' },
        areaStyle: {
          color: {
            type: 'linear',
            x: 0,
            y: 0,
            x2: 0,
            y2: 1,
            colorStops: [
              { offset: 0, color: 'rgba(54, 161, 255, 0.4)' },
              { offset: 1, color: 'rgba(54, 161, 255, 0.1)' }
            ]
          }
        }
      }
    ],
    tooltip: {
      trigger: 'axis',
      backgroundColor: 'rgba(255,255,255,0.9)',
      borderColor: '#eee',
      borderWidth: 1,
      padding: 10,
      textStyle: { color: '#333' },
      formatter: (params: ChartTooltipParam[]) =>
      params?.[0] ? `${params[0].axisValue}<br/>温度: ${params[0].data}°C` : ''
    }
  };

  private timerId: number | null = null;

  // 生成基于上一个值小范围波动的温度值（减少抖动）
  private generateRandomTemp(): number {
    const min = 10;
    const max = 40;
    const range = 1; // 波动范围±1°C
    // 基于上一个值生成新值，控制波动幅度
    let newValue = this.lastTemp + (Math.random() - 0.5) * 2 * range;
    // 确保在有效范围内
    newValue = Math.max(min, Math.min(max, newValue));
    newValue = Math.round(newValue); // 保持整数
    this.lastTemp = newValue; // 更新上一个值
    return newValue;
  }

  private getCurrentTime(): string {
    const pad = (n: number) => n.toString().padStart(2, '0');
    const now = new Date();
    return `${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;
  }

  startMonitoring(): void {
    if (this.timerId !== null) return;

    // 调整更新间隔为2秒，减少更新频率
    this.timerId = setInterval(() => {
      const newTemp = this.generateRandomTemp();
      const newTime = this.getCurrentTime();

      this.currentTemp = newTemp;
      this.temperatures = [...this.temperatures, newTemp].slice(-20);
      this.timeLabels = [...this.timeLabels, newTime].slice(-20);

      // 类型断言：明确 xAxis 类型为 ChartXAxis
      (this.chartOptions.xAxis as ChartXAxis).data = this.timeLabels;

      // 类型守卫 + 断言：利用 ChartSeries 可选属性兼容
      if (Array.isArray(this.chartOptions.series)) {
        const series = this.chartOptions.series as ChartSeries[];
        if (series.length > 0) {
          series[0].symbol = 'circle';    // 可选属性赋值（实际存在，无报错）
          series[0].symbolSize = 8;      // 可选属性赋值（实际存在，无报错）
          series[0].data = this.temperatures;
        }
      }

      this.myChart?.setOption(this.chartOptions);
    }, 2000) as number; // 从1000ms调整为2000ms
  }

  stopMonitoring(): void {
    if (this.timerId !== null) {
      clearInterval(this.timerId);
      this.timerId = null;
    }
  }

  aboutToDisappear(): void {
    this.stopMonitoring();
  }

  build() {
    Column() {
      Text('温度实时监控')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 10 })
        .fontColor('#333');

      Column() {
        Text('当前温度')
          .fontSize(16)
          .fontColor('#666')
          .margin({ bottom: 5 });
        Row() {
          Text(this.currentTemp.toString())
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333');
          Text('°C')
            .fontSize(24)
            .margin({ left: 5, top: 5 })
            .fontColor('#666');
        }
      }
      .width('90%')
      .padding(20)
      .backgroundColor('#fff')
      .borderRadius(16)
      .shadow({ radius: 8, color: '#e0e0e0', offsetX: 0, offsetY: 4 })
      .margin({ bottom: 20 });

      Stack() {
        // 修正：通过双向绑定传递myChart，由组件内部初始化实例
        hmChart({ Options: this.chartOptions, myChart: $myChart })
          .width('100%')
          .height(300);

        Text('温度变化趋势')
          .fontSize(16)
          .fontColor('#666')
          .position({ x: '5%', y: '5%' });
      }
      .width('90%')
      .height(300)
      .backgroundColor('#fff')
      .borderRadius(16)
      .shadow({ radius: 8, color: '#e0e0e0', offsetX: 0, offsetY: 4 })
      .margin({ bottom: 20 });

      Row() {
        Button('开始监控')
          .onClick(() => this.startMonitoring())
          .width(120)
          .height(40)
          .backgroundColor('#36a1ff')
          .fontColor('#fff')
          .fontSize(16);
        Button('停止监控')
          .onClick(() => this.stopMonitoring())
          .width(120)
          .height(40)
          .backgroundColor('#ff6b81')
          .fontColor('#fff')
          .fontSize(16)
          .margin({ left: 20 });
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8f9fa')
    .justifyContent(FlexAlign.Center);
  }
}

export { TemperatureMonitor };