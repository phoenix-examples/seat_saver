module SeatSaver where

import Html exposing (..)
import Html.Attributes exposing (class)

import StartApp exposing (App)
import Effects exposing (Effects, Never)
import Task exposing (Task)

import Http
import Json.Decode as Json exposing ((:=))


-- MODEL

type alias Seat =
  { seatNo : Int
  , occupied : Bool
  }


type alias Model =
  List Seat


init : (Model, Effects Action)
init =
  ([], fetchSeats)


-- UPDATE

type Action = NoOp | SetSeats (Maybe Model)


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp ->
      (model, Effects.none)
    SetSeats seats ->
      (Maybe.withDefault model seats, Effects.none)


-- VIEW

view : Signal.Address Action -> Model -> Html
view address model =
  ul [ class "seats" ] ( List.map (seatItem address) model )


seatItem : Signal.Address Action -> Seat -> Html
seatItem address seat =
  li [ class "seat available" ] [ text (toString seat.seatNo) ]


-- EFFECTS

fetchSeats =
  Http.get decodeSeat "http://localhost:4000/api/seats"
    |> Task.toMaybe
    |> Task.map SetSeats
    |> Effects.task


decodeSeat =
  let seat =
        Json.object2 (\seatNo occupied -> (Seat seatNo occupied))
          ("seatNo" := Json.int)
          ("occupied" := Json.bool)
  in
      Json.at ["data"] (Json.list seat)


-- WIRING

app : App Model
app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = []
    }


main : Signal Html
main =
  app.html


port tasks : Signal (Task Never ())
port tasks =
  app.tasks
