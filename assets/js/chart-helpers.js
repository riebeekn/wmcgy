const DATALABEL_COLOR = "#F4F4F5";
const TOOLTIP_TEXT_COLOR = "#18181B";
const TOOLTIP_BG_COLOR = "#EAEBE5";

const CHART_COLORS = {
  blue: "#2563EB",
  red: "#DC2626",
  teal: "#0D9488",
  orange: "#EA580C",
  yellow: "#EAB308",
  purple: "#9333EA",
  pink: "#DB2777",
  green: "#16A34A",
  amber: "#D97706",
  cyan: "#14B8A6",
  lime: "#84CC16",
};

function basicTooltip(tooltipItem) {
  let val = toCurrency(tooltipItem.raw);

  return `${tooltipItem.dataset.label} ${val}`;
}

function toCurrency(value) {
  var formatter = new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
  });
  return formatter.format(value);
}

function truncateString(str, num) {
  if (str?.length > num) {
    return str.slice(0, num) + "...";
  } else {
    return str;
  }
}

export {
  CHART_COLORS,
  DATALABEL_COLOR,
  TOOLTIP_TEXT_COLOR,
  TOOLTIP_BG_COLOR,
  basicTooltip,
  toCurrency,
  truncateString,
};
