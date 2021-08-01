shared_attrs = %{
  auth: %{
    auth_type: "oauth2",
    connection_info: %{
      "authorize" => %{
        "params" => %{
          "client_id" => "<%= config[\"client_id\"] %>",
          "redirect_uri" => "<%= meta.redirect_uri %>",
          "response_type" => "code",
          "state" => "<%= meta.state %>"
        },
        "url" => "https://platform.devtest.ringcentral.com/restapi/oauth/authorize"
      },
      "get_token" => %{
        "body" => %{
          "code" => "<%= input.code %>",
          "grant_type" => "authorization_code",
          "redirect_uri" => "<%= meta.redirect_uri %>"
        },
        "headers" => %{
          "authorization" => "Basic <%= config[\"authorization\"] %>",
          "content-type" => "application/x-www-form-urlencoded"
        },
        "method" => "POST",
        "url" => "https://platform.devtest.ringcentral.com/restapi/oauth/token"
      }
    }
  },
  run_info: %{
    adapter: "local",
    source_code: ~S"""
    """
  },
  config: %{}
}

{:ok, connector} =
  Flowr.Exterior.create_connector(
    %{
      name: "Transcoder",
      description: "Transcoder",
      functions: [
        %{
          name: "video_to_image",
          arg_template: %{
            "video_uri" => "{VIDEO_URI}"
          }
        },
        %{
          name: "video_to_text",
          arg_template: %{
            "video_uri" => "{VIDEO_URI}",
            "language" => "{LANGUAGE}"
          }
        },
        %{
          name: "audio_to_text",
          arg_template: %{
            "audio_uri" => "{AUDIO_URI}",
            "language" => "{LANGUAGE}"
          }
        }
      ]
    }
    |> Map.merge(shared_attrs)
  )

{:ok, connector} =
  Flowr.Exterior.create_connector(
    %{
      name: "Machine Learning",
      description: "ML",
      functions: [
        %{
          name: "object_detection",
          arg_template: %{
            "video_uri" => "{VIDEO_URI}",
            "object" => "{OBJECT}"
          }
        }
      ]
    }
    |> Map.merge(shared_attrs)
  )

{:ok, connector} =
  Flowr.Exterior.create_connector(
    %{
      name: "Salesforce",
      description: "Salesforce",
      functions: [
        %{
          name: "add_record",
          arg_template: %{
            "content" => "{CONTENT}"
          }
        }
      ]
    }
    |> Map.merge(shared_attrs)
  )

{:ok, connector} =
  Flowr.Exterior.create_connector(
    %{
      name: "Google Sheets",
      description: "Google Sheets",
      functions: [
        %{
          name: "insert_row",
          arg_template: %{
            "row" => "{CSV_CONTENT}"
          }
        }
      ]
    }
    |> Map.merge(shared_attrs)
  )

{:ok, connector} =
  Flowr.Exterior.create_connector(
    %{
      name: "Filter",
      description: "Simple filter",
      functions: [
        %{
          name: "filter_data",
          arg_template: %{
            "filter_by" => "{FILTER_BY}"
          }
        }
      ]
    }
    |> Map.merge(shared_attrs)
  )

{:ok, connector} =
  Flowr.Exterior.create_connector(
    %{
      name: "RingCentral",
      description: "RingCentral services",
      functions: [
        %{
          name: "create_sms",
          arg_template: %{
            "content" => "{CONTENT}"
          }
        },
        %{
          name: "create_fax",
          arg_template: %{
            "content" => "{CONTENT}"
          }
        },
        %{
          name: "ringout",
          arg_template: %{
            "phone_number" => "{PHONE_NUMBER}"
          }
        }
      ]
    }
    |> Map.merge(shared_attrs)
  )
