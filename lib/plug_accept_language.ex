defmodule PlugAcceptLanguage do
  def list(conn) do
    conn
    |> Plug.Conn.get_req_header("accept-language")
    |> parse_header([])
    |> Enum.sort(fn({_, a}, {_, b}) -> a > b end)
    |> Enum.map(&(elem(&1, 0)))
  end

  defp parse_header([], acc) do
    acc
  end
  defp parse_header([value | rest], acc) do
    acc = value
    |> Plug.Conn.Utils.list()
    |> Enum.reduce(acc, &parse_language/2)
    parse_header(rest, acc)
  end

  defp parse_language(<<>>, acc) do
    acc
  end
  defp parse_language(<<" ", rest :: binary>>, acc) do
    parse_language(rest, acc)
  end
  for ll <- 1..10 do
    for ws <- 0..20 do
      ws = Stream.repeatedly(fn -> " " end) |> Enum.take(ws) |> Enum.join("")
      defp parse_language(<<locale :: binary-size(unquote(ll)), (unquote(ws <> ";")), rest :: binary>>, acc) do
        q = rest |> Plug.Conn.Utils.params() |> to_q
        [{locale, q} | acc]
      end
    end
    defp parse_language(<<locale :: binary-size(unquote(ll)), " ", _ :: binary>>, acc) do
      [{locale, 1.0} | acc]
    end
  end
  defp parse_language(locale, acc) do
    [{locale, 1.0} | acc]
  end

  defp to_q(%{"q" => q}) do
    case Float.parse(q) do
      { num, _ } -> num
      :error -> 1.0
    end
  end
  defp to_q(_), do: 1.0
end
