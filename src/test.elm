module Main exposing (Model)

import Browser
import Html exposing (..)
import Html.Events exposing (onClick)
import Http


type alias Model =
    List String


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick SendHttpRequest ]
            [ text "Get data from server" ]
        , h3 [] [ text "Old School Main Characters" ]
        , ul [] (List.map viewNickname model)
        ]


viewNickname : String -> Html Msg
viewNickname nickname =
    li [] [ text nickname ]


type Msg
    = SendHttpRequest
    | DataReceived (Result Http.Error String)


url : String
url =
    "http://localhost:8080/oldschool.txt"


getNicknames : Cmd Msg
getNicknames =
    Http.get
        { url = url
        , expect = Http.expectString DataReceived
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SendHttpRequest ->
            ( model, getNicknames )

        DataReceived result ->
            case result of
                Ok nicknameStr ->
                    let
                        nicknames =
                            String.split "," nicknameStr
                    in
                    ( nicknames, Cmd.none )

                Err httpError ->
                    ( model, Cmd.none )


main : Program () Model Msg
main =
    Browser.element
        { init = \flags -> ( [], Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
