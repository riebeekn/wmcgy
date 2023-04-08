import Chart from "chart.js/auto";
import ChartDataLabels from "chartjs-plugin-datalabels";

import {
  CHART_COLORS,
  DATALABEL_COLOR,
  TOOLTIP_BG_COLOR,
  TOOLTIP_TEXT_COLOR,
  toCurrency,
} from "./chart-helpers";

class PieChart {
  constructor(ctx) {
    this.chart = new Chart(ctx, {
      type: "pie",
      plugins: [
        ChartDataLabels,
        {
          id: "noDataPlugin",
          afterDraw: (chart) => {
            if (chart.data.labels.length === 0) {
              var ctx = chart.ctx;
              var width = chart.width;
              var height = chart.height;
              ctx.textAlign = "center";
              ctx.textBaseline = "middle";
              ctx.font = "16px 'Inter var'";
              ctx.fillText("No data to display", width / 2, height / 2);
            }
          },
        },
      ],
      options: {
        plugins: {
          legend: {
            display: false,
          },

          datalabels: {
            color: DATALABEL_COLOR,
            font: {
              weight: "bold",
            },
            align: "center",
            formatter: (value, ctx) => {
              let label = ctx.chart.data.labels[ctx.dataIndex];
              label = this.truncateString(label, 15);
              let percentage =
                ctx.chart.data.datasets[0].percentage[ctx.dataIndex] ?? 0;

              if (percentage > 10) {
                return `${label}\n${percentage} %`;
              } else {
                return "";
              }
            },
          },
          tooltip: {
            enabled: true,
            displayColors: false,
            backgroundColor: TOOLTIP_BG_COLOR,
            titleColor: TOOLTIP_TEXT_COLOR,
            bodyColor: TOOLTIP_TEXT_COLOR,
            callbacks: {
              title: function (tooltipItem) {
                return tooltipItem.label;
              },
              label: function (tooltipItem) {
                let dataIndex = tooltipItem.dataIndex;
                let rawValue = tooltipItem.parsed;
                let percentageValue = tooltipItem.dataset.percentage[dataIndex];

                return `${toCurrency(rawValue)} (${percentageValue}%)`;
              },
            },
          },
        },
      },
    });
  }

  updateData(labels, values, percentages) {
    this.chart.data = {
      labels: labels,
      datasets: [
        {
          backgroundColor: Object.values(CHART_COLORS),
          data: values,
          percentage: percentages,
        },
      ],
    };

    this.chart.update();
  }

  truncateString(str, num) {
    if (str?.length > num) {
      return str.slice(0, num) + "...";
    } else {
      return str;
    }
  }
}

export default PieChart;
