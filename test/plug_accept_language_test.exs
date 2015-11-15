defmodule PlugAcceptLanguage.Test do
  use ExUnit.Case, async: false
  use ExCheck
  use Plug.Test

  def smaller(domain, factor \\ 2) do
    sized fn(size) ->
      resize(:random.uniform((div(size, factor))+1), domain)
    end
  end

  defp dec do
    bind real, fn(value) ->
      abs(value - trunc(value)) |> to_string
    end
  end

  defp locale do
    oneof ["aa", "agq", "ak", "as", "asa", "ast", "bas", "be", "bem", "bez", "bm", "bo",
           "br", "brx", "bs", "byn", "cgg", "chr", "dav", "dje", "dua", "dyo", "dz",
           "ebu", "ee", "eo", "ewo", "ff", "fo", "fur", "ga", "gd", "gsw", "guz", "gv",
           "ha", "haw", "ia", "ig", "ii", "jgo", "jmc", "kab", "kam", "kde", "kea",
           "khq", "ki", "kkj", "kl", "kln", "kok", "ks", "ksb", "ksf", "ksh", "kw",
           "lag", "lg", "lkt", "ln", "lu", "luo", "luy", "mas", "mer", "mfe", "mg",
           "mgh", "mgo", "mt", "mua", "naq", "nd", "nmg", "nn", "nnh", "nr", "nso",
           "nus", "nyn", "om", "or", "os", "ps", "rm", "rn", "rof", "rw", "rwk", "sah",
           "saq", "sbp", "se", "seh", "ses", "sg", "shi", "sn", "so", "ss", "ssy", "st",
           "swc", "teo", "tg", "ti", "tig", "tn", "to", "ts", "twq", "tzm", "ug", "vai",
           "ve", "vo", "vun", "wae", "wal", "xh", "xog", "yav", "yo", "zgh", "no", "af",
           "am", "ar", "bg", "cs", "da", "de", "el", "es", "et", "eu", "fa", "fi", "fy",
           "gl", "he", "hr", "id", "is", "ja", "km", "kn", "ko", "ky", "lt", "lv", "ml",
           "mn", "my", "nb", "nl", "pa", "pl", "pt", "root", "ru", "si", "sk", "sl",
           "sr", "sw", "ta", "te", "th", "tr", "uk", "ur", "uz", "zh", "zu"]
  end

  defp string do
    bind unicode_binary, &String.replace(&1, ",", "")
  end

  defp param do
    oneof([
      ["q", dec],
      [string, string]
    ])
  end

  defp params do
    oneof [
      bind(smaller(list(param), 2), &Enum.join(&1, ";")),
      ""
    ]
  end

  defp ws do
    bind int(0, 10), fn(count) ->
      Stream.repeatedly(fn -> " " end) |> Enum.take(count) |> Enum.join("")
    end
  end

  defp header do
    bind {ws, locale, ws, ws, params, ws}, fn
      ({w1, l, w2, _, "", _}) ->
        [w1,l,w2,"","","",""]
      ({w1, l, w2, w3, p, w4}) ->
        [w1,l,w2,";",w3,p,w4]
    end
  end

  defp accepts do
    smaller(list(header), 2)
  end

  @tag timeout: :infinity
  property :plug_x_forwarded_for do
    for_all hs in list(accepts) do
      conn = Enum.reduce(hs, conn(:get, "/"), fn(header, conn = %{req_headers: headers}) ->
        %{conn | req_headers: headers ++ [{"accept-language", Enum.join(header,",")}]}
      end)

      expected = hs
      |> Enum.flat_map(fn(header) ->
        Enum.map(header, fn([_,l,_,_,_,p,_]) ->
          pri = p |> Plug.Conn.Utils.params() |> Map.get("p", "1.0") |> String.to_float()
          {l, pri}
        end)
      end)
      |> Enum.reverse()
      |> Enum.sort(fn({_, a}, {_, b}) -> a > b end)
      |> Enum.map(&(elem(&1, 0)))

      actual = PlugAcceptLanguage.list(conn)

      actual == expected
    end
  end
end
