module Main exposing (..)

import Browser
import Css exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.Grid as Grid
import Http
import Json.Decode as JD exposing (Decoder, field, int, string)
import Markdown


fetchPosts : Cmd Msg
fetchPosts =
    Http.get
        { url = "http://localhost:8000/post/"
        , expect = Http.expectJson AllPostsReceived postsDecoder
        }


postsDecoder : Decoder (List Post)
postsDecoder =
    JD.list postDecoder


postDecoder : Decoder Post
postDecoder =
    JD.map3 Post
        (field "title" string)
        (field "content" string)
        (field "date" string)



---- MODEL ----


type alias Post =
    { title : String
    , content : String
    , date : String
    }


type alias Model =
    { post : Post
    , postList : List Post
    }


defaultPost =
    { title = "title"
    , content = "content"
    , date = "some date"
    }


init : ( Model, Cmd Msg )
init =
    ( { post =
            { title = "title"
            , content = "content"
            , date = "some date"
            }
      , postList = []
      }
    , fetchPosts
    )



---- UPDATE ----


type Msg
    = FetchAllPosts
    | AllPostsReceived (Result Http.Error (List Post))
    | DisplayNewPost Post


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchAllPosts ->
            ( model, fetchPosts )

        AllPostsReceived result ->
            case result of
                Ok posts ->
                    ( { model
                        | postList = posts
                        , post = Maybe.withDefault defaultPost (List.head posts)
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, Cmd.none )

        DisplayNewPost post ->
            ( { model | post = post }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        postView =
            model.postList
                |> List.map
                    (\x ->
                        div [ class "blog-menu-item" ]
                            [ button [ class "menu-item-button", onClick (DisplayNewPost x) ] [ text x.title ]
                            ]
                    )
                |> div [ class "column blog-menu" ]
    in
    div [ class "container" ]
        [ div [ class "row" ]
            [ postView
            , div [ class "column" ]
                [ div [ class "post" ]
                    [ h1 [] [ text model.post.title ]
                    , Markdown.toHtml Nothing model.post.content |> div []
                    ]
                ]
            ]
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
