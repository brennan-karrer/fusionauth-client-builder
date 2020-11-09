[#import "_macros.ftl" as global/]
require 'ostruct'
<#--  require 'fusionauth/rest_client'  -->

#
# Copyright (c) 2018-2019, FusionAuth, All Rights Reserved
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
# either express or implied. See the License for the specific
# language governing permissions and limitations under the License.
#

defmodule FusionAuthClient do
  @moduledoc """
  Testing ...
  """

[#list apis as api]
  @doc """
  [#list api.comments as comment]
  ${comment}
  [/#list]

  [#list api.params![] as param]
  ## Parameters

    [#if !param.constant??]
    - ${camel_to_underscores(param.name?replace("end", "_end"))}: [${global.convertType(param.javaType, "elixir")}] ${param.comments}
    [/#if]
  [/#list]

  Returns `FusionAuth.ClientResponse()`. The ClientResponse object.
    [#if api.deprecated??]

  @deprecated ${api.deprecated?replace("{{renamedMethod}}", camel_to_underscores(api.renamedMethod!''))}
    [/#if]
  """
  @spec ${camel_to_underscores(api.methodName)}(${global.specParameters(api, "elixir")}) :: FusionAuth.ClientResponse()
  def ${camel_to_underscores(api.methodName)}(${global.methodParameters(api, "elixir")}) do
    [#assign formPost = false/]
    [#list api.params![] as param]
      [#if param.type == "form"][#assign formPost = true/][/#if]
    [/#list]
    [#if formPost]
    body = {
      [#list api.params![] as param]
        [#if param.type == "form"]
      "${param.name}" => ${(param.constant?? && param.constant)?then("\""+param.value+"\"", param.name)}[#if param?has_next],[/#if]
        [/#if]
      [/#list]
    }
    [/#if]
    start[#if api.anonymous??]Anonymous[/#if]
    |> uri("${api.uri}")
      [#if api.authorization??]
    |> authorization(${api.authorization?replace("encodedJWT", "encoded_jwt")?replace('\'', '\"')})
      [/#if]
    [#list api.params![] as param]
      [#if param.type == "urlSegment"]
    |> url_segment(${(param.constant?? && param.constant)?then(param.value, camel_to_underscores(param.name))})
      [#elseif param.type == "urlParameter"]
    |> url_parameter("${param.parameterName}", ${(param.constant?? && param.constant)?then(param.value, camel_to_underscores(param.name?replace("end", "_end")))})
      [#elseif param.type == "body"]
    |> body_handler(FusionAuth::JSONBodyHandler.new(${camel_to_underscores(param.name)}))
      [/#if]
    [/#list]
      [#if formPost]
    |> body_handler(FusionAuth::FormDataBodyHandler.new(body))
      [/#if]
    |> ${api.method}()
    |> go()
  end

[/#list]
end
