defmodule Tirexs.Percolator do
  @moduledoc false

  use Tirexs.DSL.Logic

  alias Tirexs.Query, as: Query

  def transpose(block) do
    case block do
      {:query, _, [params]} -> Query._query(params[:do])
      {:query, _, options}  -> Query._query(options)
      {:doc, _, [params]}   -> doc(params[:do])
      {:doc, _, options}   -> doc(options)
    end
  end

  defmacro percolator([do: block]) do
    extract(block)
  end

  defmacro percolator(options, [do: block]) do
    [options, index_opts] = Tirexs.Search.extract_index_options(options)
    extract(block) ++ options ++ index_opts
  end

  def doc(options, doc_opts \\ []) do
    options = List.first(extract_block(options))
    [doc: extract_block(options) ++ doc_opts]
  end

  @doc false
  def create_resource(definition, settings) do
    url  = "#{definition[:index]}/.percolator/#{definition[:name]}"
    json = to_resource_json(definition)

    Tirexs.ElasticSearch.put(url, json, settings)
  end

  @doc false
  def to_resource_json(definition) do
    definition = Dict.delete(definition, :index)
    definition = Dict.delete(definition, :type)
    definition = Dict.delete(definition, :name)
    JSX.encode!(definition)
  end

  def match(definition, settings) do
    url  = "#{definition[:index]}/#{definition[:type]}/_percolate"
    json = to_resource_json(definition)

    Tirexs.ElasticSearch.post(url, json, settings)
  end

end
