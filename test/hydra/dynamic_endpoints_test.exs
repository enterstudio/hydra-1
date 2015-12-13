defmodule Hydra.DynamicEndpointsTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Hydra.DynamicEndpoints
  alias Hydra.Endpoint
  alias Hydra.EndpointStorage

  @opts DynamicEndpoints.init([])
  @json_mime "application/json"

  def request(:get, path) do
    conn(:get, path)
    |> put_req_header("content-type", @json_mime)
    |> DynamicEndpoints.call(@opts)
  end

  defmodule ExampleRouter do
    use Plug.Router
    plug Plug.Parsers, parsers: [:urlencoded, :json],
                       pass:  ["text/*"],
                       json_decoder: Poison
    plug :match
    plug :dispatch

    get "/foo" do
      send_resp(conn, 200, Poison.encode!(%{foo: "bar"}))
    end

    get "/bar" do
      send_resp(conn, 200, Poison.encode!(%{bar: 42}))
    end
  end

  setup do
    EndpointStorage.register(%Endpoint{path: "/dynamic", requests: ["http://localhost:9999/foo", "http://localhost:9999/bar"]})

    {:ok, pid} = Plug.Adapters.Cowboy.http(ExampleRouter, [], [port: 9999])
    on_exit(fn -> Plug.Adapters.Cowboy.shutdown(pid) end)

    :ok
  end

  test "dispatch dynamic endpoint" do
    conn = request(:get, "/dynamic")
    assert conn.state == :sent
    assert conn.status == 200

    assert %{"foo" => "bar", "bar" => 42} == Poison.decode!(conn.resp_body)
  end
end
