open Base
open Parselib
let printProtocol (traits : Trait.t list option) =
  ((traits |> (Option.value ~default:[])) |>
     (List.find_map
        ~f:(function
            | Trait.AwsProtocolAwsJson1_0Trait -> ((Some ("AWS JSON 1.0"))
                [@explicit_arity ])
            | Trait.AwsProtocolAwsJson1_1Trait -> ((Some ("AWS JSON 1.1"))
                [@explicit_arity ])
            | Trait.AwsProtocolRestJson1Trait -> ((Some ("AWS REST JSON 1"))
                [@explicit_arity ])
            | Trait.AwsProtocolRestXmlTrait -> ((Some ("AWS REST XML"))
                [@explicit_arity ])
            | Trait.AwsProtocolAwsQueryTrait -> ((Some ("AWS Query"))
                [@explicit_arity ])
            | Trait.AwsProtocolEc2QueryTrait -> ((Some ("EC2 Query"))
                [@explicit_arity ])
            | _ -> None)))
    |> (Option.value ~default:"<unknown>")
let printServiceTrait traits =
  ((traits |> (Option.value ~default:[])) |>
     (List.find_map
        ~f:(function
            | ((Trait.ServiceTrait
                ({ sdkId; arnNamespace; endpointPrefix;_}))[@explicit_arity ])
                ->
                ((Some
                    ((Fmt.str "{ Sdk %s Namespace %s endpointPrefix %s }"
                        sdkId arnNamespace
                        (Option.value endpointPrefix ~default:"<>"))))
                [@explicit_arity ])
            | _ -> None)))
    |> (Option.value ~default:"<unknown>")
let printOperations operations =
  (operations |>
     (List.filter_map
        ~f:(function
            | Shape.{ name;
                      descriptor = ((Shape.OperationShape
                        ({ input; output;_}))[@explicit_arity ])
                      } 
                ->
                ((Some
                    ((Printf.sprintf "operation %s = %s => %s" name
                        (Option.value input ~default:"()")
                        (Option.value output ~default:"void"))))
                [@explicit_arity ])
            | _ -> None)))
    |> (List.iter ~f:(fun str -> Stdio.print_endline str))
let printServiceDetails shapes =
  List.iter shapes
    ~f:(fun Shape.{ descriptor;_}  ->
          match descriptor with
          | ((Shape.ServiceShape (details))[@explicit_arity ]) ->
              Stdio.printf "Service: version=%s\n, protocol=%s, %s"
                details.version (printProtocol details.traits)
                (printServiceTrait details.traits)
          | _ -> ())