open Base
open Parselib

let generateServiceMetadata (service : Ast.Shape.serviceShapeDetails) fmt =
  Fmt.pf fmt "let service =@;<0 2>@[<v 0>";
  Fmt.pf fmt "Aws.Service.{@;<0 2>@[<v 0>";
  let serviceDetails =
    List.find_map_exn (Option.value service.traits ~default:[]) ~f:(function
      | Ast.Trait.ServiceTrait x -> Some x
      | _ -> None)
  in
  Fmt.pf fmt "namespace = \"%s\";@;endpointPrefix = \"%s\";@;version = \"%s\""
    serviceDetails.arnNamespace
    (Option.value serviceDetails.endpointPrefix ~default:"")
    service.version;
  Fmt.pf fmt "@]@\n};@]@\n"

let generateServiceInterface service fmt = Fmt.pf fmt "val service : Aws.Service.descriptor@\n@\n"

let generateStructureShapes structure_shapes fmt =
  structure_shapes
  |> List.map ~f:(function
       | Ast.Dependencies.
           { recursWith = ((Some recursItems) [@explicit_arity]); name; descriptor; _ } ->
           Codegen.Types.generateRecursiveTypeBlock
             ((let open Ast.Shape in
               { name; descriptor })
             :: List.map recursItems ~f:(fun item ->
                    let open Ast.Shape in
                    { name = item.name; descriptor = item.descriptor }))
             ~genDoc:true ()
       | Ast.Dependencies.{ name; descriptor; _ } ->
           Codegen.Types.generateTypeBlock
             (let open Ast.Shape in
              { name; descriptor })
             ~genDoc:true ())
  |> String.concat ~sep:"\n\n"
  |> fun __x -> Fmt.pf fmt "%s\n\n" __x

let generate ~name ~(service : Ast.Shape.serviceShapeDetails) ~operation_shapes ~structure_shapes
    fmt =
  Fmt.pf fmt "open Aws_SmSdk_Lib@\n";
  generateServiceMetadata service fmt;
  generateStructureShapes structure_shapes fmt

let generate_mli ~name ~service ~operation_shapes ~structure_shapes ?(no_open = false) fmt =
  if not no_open then Fmt.pf fmt "open Aws_SmSdk_Lib@\n";

  generateServiceInterface service fmt;
  generateStructureShapes structure_shapes fmt
