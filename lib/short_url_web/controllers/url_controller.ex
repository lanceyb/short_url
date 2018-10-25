defmodule ShortUrlWeb.UrlController do
  use ShortUrlWeb, :controller

  def redirect_to(conn, %{ "code" => code } = _params) do
    val = get_url_by_code(code) |> case do
      {:ok, nil} -> "404"
      {:ok, url} -> url
      _ -> "404"
    end
    if Regex.match?(~r/\Ahttp(s)?:\/\/\w+/, val) do
      redirect conn, external: val
    else
      redirect conn, external: "http://ewanse.com/404.html"
    end
  end

  def create(conn, %{ "url" => url } = _params) do
    val = set_id() |> case do
      {:ok, id} -> %{ biz_action: 0, biz_msg: "ok", data: %{ id: store_url(id, url) } }
      _ -> %{ biz_action: 1, biz_msg: "fail", data: %{} }
    end

    json conn, val
  end

  def get_url_by_code(code) do
    key = "short" <> String.slice(code, 0, 3)
    hkey = String.slice(code, 3, String.length(code) - 3)
    ShortUrl.Redix.command(["HGET", key, hkey])
  end

  def store_url(id, url) do
    if id === 1 do
      expire_hashed()
    end

    code = String.pad_leading(List.to_string(ShortUrl.ThirtyFourCal.tranform(id)), 3, "0")
    ShortUrl.Redix.command(["HMSET", hashed_key(), code, url])
                  |> case do
                    {:ok, "OK"} -> List.to_string(hashed_key_list()) <> code
                    _ -> raise "unknown"
                  end
  end

  def expire_hashed do
    # hash有效期是1个月（30天）
    # 7776000是90天，另外的60天为冗余时间
    ShortUrl.Redix.command(["EXPIRE", hashed_key(), 7776000])
  end

  def set_id do
    ShortUrl.Redix.command(["INCR", cursor_key()])
  end

  def year_and_month_str do
    {{year, month, _}, _} = :erlang.localtime
    Integer.to_string(year) <> String.pad_leading(Integer.to_string(month), 2, "0")
  end

  def hashed_key_list do
    [ _, _ | short_d_m ] = String.to_charlist(year_and_month_str())
    ShortUrl.ThirtyFourCal.tranform(List.to_integer(short_d_m))
  end

  def hashed_key do
    "short" <> List.to_string(hashed_key_list())
  end

  def cursor_key do
    "short" <> year_and_month_str() <> "-" <> "cursor"
  end
end
