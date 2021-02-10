module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Url



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , content : String
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( Model key url "LOADING PAGE..."
    , Http.get
        { url = "/api/random"
        , expect = Http.expectString GotText
        }
    )


get_name_from_path : String -> String
get_name_from_path fulPath =
    case fulPath of
        "/random" ->
            "Random"

        "/about" ->
            "About"

        _ ->
            "Error"


get_api_path : Url.Url -> String
get_api_path url =
    "/api" ++ url.path


gen_url_change : Url.Url -> String -> Msg
gen_url_change url new_path =
    let
        new_url =
            { url | path = new_path }
    in
    UrlChanged new_url



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotText (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            link_clinked model urlRequest

        UrlChanged url ->
            url_changed model url

        GotText result ->
            rcv_txt model result


link_clinked : Model -> Browser.UrlRequest -> ( Model, Cmd Msg )
link_clinked model urlRequest =
    case urlRequest of
        Browser.Internal url ->
            ( model, Nav.pushUrl model.key (Url.toString url) )

        Browser.External href ->
            ( model, Nav.load href )


url_changed : Model -> Url.Url -> ( Model, Cmd Msg )
url_changed model url =
    let
        new_url =
            get_api_path url
    in
    ( { model | url = url }
    , Http.get
        { url = new_url
        , expect = Http.expectString GotText
        }
    )


rcv_txt : Model -> Result Http.Error String -> ( Model, Cmd Msg )
rcv_txt model result =
    case result of
        Ok fullText ->
            ( { model | content = fullText }, Cmd.none )

        Err e ->
            let
                strError =
                    treat_error e
            in
            ( { model | content = strError }, Cmd.none )


treat_error : Http.Error -> String
treat_error e =
    case e of
        Http.BadUrl u ->
            "BadUrl " ++ u

        Http.Timeout ->
            "Timeout"

        Http.BadStatus i ->
            "Status" ++ String.fromInt i

        Http.NetworkError ->
            "Network"

        Http.BadBody b ->
            "Badbody " ++ b



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Page"
    , body =
        [ h1 [] [ text "Lorna's Random Facts" ]
        , view_nav
        , view_div "app"
            [ view_content model
            ]
        ]
    }


view_div : String -> List (Html Msg) -> Html Msg
view_div name content =
    div [ id name ] content


view_nav : Html Msg
view_nav =
    nav []
        [ ul []
            [ view_link "/random"
            , view_link "/about"
            ]
        ]


view_link : String -> Html Msg
view_link path =
    let
        name =
            get_name_from_path path
    in
    li [] [ a [ href path ] [ text name ] ]


view_content : Model -> Html Msg
view_content model =
    case model.url.path of
        "/" ->
            view_random model

        "/random" ->
            view_random model

        "/about" ->
            view_about model

        _ ->
            view_error model


view_random : Model -> Html Msg
view_random model =
    view_div "random"
        [ p [] [ text model.content ]
        , button [ onClick (gen_url_change model.url "/random") ] [ text "New" ]
        ]


view_about : Model -> Html Msg
view_about model =
    view_div "about"
        [ p [] [ text model.content ]
        ]


view_error : Model -> Html Msg
view_error model =
    view_div "error"
        [ h2 [] [ text "Error" ]
        , text model.content
        ]
