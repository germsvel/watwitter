defmodule WatwitterWeb.DateHelpers do
  def format_short(%{month: month, day: day}) do
    "#{format_month(month)} #{day}"
  end

  def format_month(1), do: "Jan"
  def format_month(2), do: "Feb"
  def format_month(3), do: "Mar"
  def format_month(4), do: "Apr"
  def format_month(5), do: "May"
  def format_month(6), do: "June"
  def format_month(7), do: "July"
  def format_month(8), do: "Aug"
  def format_month(9), do: "Sept"
  def format_month(10), do: "Oct"
  def format_month(11), do: "Nov"
  def format_month(12), do: "Dec"
end
