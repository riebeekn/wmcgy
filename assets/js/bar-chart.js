import Chart from "chart.js/auto";

import {
  TOOLTIP_BG_COLOR,
  TOOLTIP_TEXT_COLOR,
  basicTooltip,
  updateChartDatasets,
} from "./chart-helpers";

class BarChart {
  constructor(ctx) {
    this.chart = new Chart(ctx, {
      type: "bar",
      options: {
        plugins: {
          legend: {
            display: true,
            position: "bottom",
          },
          tooltip: {
            enabled: true,
            displayColors: false,
            backgroundColor: TOOLTIP_BG_COLOR,
            titleColor: TOOLTIP_TEXT_COLOR,
            bodyColor: TOOLTIP_TEXT_COLOR,
            callbacks: {
              label: function (tooltipItem) {
                return basicTooltip(tooltipItem);
              },
            },
          },
        },
      },
    });
  }

  updateData(labels, datasets) {
    updateChartDatasets(this.chart, labels, datasets);
  }
}

export default BarChart;
