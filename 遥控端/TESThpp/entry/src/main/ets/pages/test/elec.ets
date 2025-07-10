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

interface ChartSeries {
  name: string;
  type: 'line';
  data: number[];
  smooth: boolean;
  symbol?: 'circle';
  symbolSize?: number;
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
struct ECMonitor {
  @State myChart: hmChartType | null = null;
  @State ecValues: number[] = []; // 电导率数据数组
  @State timeLabels: string[] = [];
  @State currentEc: number = 0; // 当前电导率值

  // 图表配置适配电导率范围（50~500 μS/cm）
  private chartOptions: ChartOptions = {
    xAxis: {
      type: 'category',
      data: [],
      axisLine: { lineStyle: { color: '#888' } },
      axisLabel: { color: '#666' }
    },
    yAxis: {
      type: 'value',
      min: 50, // 电导率最小值
      max: 500, // 电导率最大值
      splitLine: { lineStyle: { color: '#f0f0f0' } },
      axisLabel: { formatter: '{value} μS/cm', color: '#666' } // 单位改为μS/cm
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
        name: '电导率', // 系列名称修改
        type: 'line',
        data: [],
        smooth: true,
        symbol: 'circle',
        symbolSize: 8,
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
      params?.[0] ? `${params[0].axisValue}<br/>电导率: ${params[0].data} μS/cm` : '' // 提示框文本修改
    }
  };

  private timerId: number | null = null;

  // 生成50~500 μS/cm之间的随机电导率值（保留1位小数）
  private generateRandomEc(): number {
    const min = 50;
    const max = 500;
    return Number((Math.random() * (max - min) + min).toFixed(1));
  }

  private getCurrentTime(): string {
    const pad = (n: number) => n.toString().padStart(2, '0');
    const now = new Date();
    return `${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;
  }

  startMonitoring(): void {
    if (this.timerId !== null) return;

    this.timerId = setInterval(() => {
      const newEc = this.generateRandomEc();
      const newTime = this.getCurrentTime();

      this.currentEc = newEc;
      this.ecValues = [...this.ecValues, newEc].slice(-20); // 保留最近20条数据
      this.timeLabels = [...this.timeLabels, newTime].slice(-20);

      // 更新X轴数据
      (this.chartOptions.xAxis as ChartXAxis).data = this.timeLabels;

      // 更新系列数据
      if (Array.isArray(this.chartOptions.series)) {
        const series = this.chartOptions.series as ChartSeries[];
        if (series.length > 0) {
          series[0].data = this.ecValues;
        }
      }

      this.myChart?.setOption(this.chartOptions);
    }, 1000) as number;
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
      Text('电导率实时监控') // 标题修改
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 10 })
        .fontColor('#333');

      Column() {
        Text('当前电导率') // 显示文本修改
          .fontSize(16)
          .fontColor('#666')
          .margin({ bottom: 5 });
        Row() {
          Text(this.currentEc.toString())
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333');
          Text('μS/cm') // 单位修改
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
        hmChart({ Options: this.chartOptions, myChart: $myChart })
          .width('100%')
          .height(300);

        Text('电导率变化趋势') // 趋势图标题修改
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