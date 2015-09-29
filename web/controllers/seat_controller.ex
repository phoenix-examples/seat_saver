defmodule SeatSaver.SeatController do
  use SeatSaver.Web, :controller

  alias SeatSaver.Seat

  def index(conn, _params) do
    query = from s in Seat, order_by: [asc: s.seat_no]
    seats = query |> Repo.all
    render(conn, "index.json", seats: seats)
  end
end
