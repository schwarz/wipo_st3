defmodule WipoSt3 do
  @moduledoc """
  WIPO ST.3 codes of states, other entities and intergovernmental organizations.

      iex> WipoSt3.name(:qz)
      "Community Plant Variety Office (European Union) (CPVO)"
  """

  @codes_path Path.expand("../priv/wipo_st3_codes.json", __DIR__)
  @external_resource @codes_path

  # Codes come from our own bundled dataset, so turning them into atoms is safe.
  @codes @codes_path
         |> File.read!()
         |> JSON.decode!()
         |> Enum.map(fn
           %{"code" => code, "name" => name} ->
             {String.to_atom(code), name}

           unexpected ->
             raise ArgumentError,
                   "expected a code/name pair in #{@codes_path}, got: #{inspect(unexpected)}"
         end)

  # Issues with the data are easiest caught here.
  if @codes == [] or length(@codes) != map_size(Map.new(@codes)) do
    raise ArgumentError, "expected #{@codes_path} to hold a non-empty list of unique codes"
  end

  @codes_by_name Enum.sort_by(@codes, fn {code, name} ->
                   # drop unicode accents and marks
                   sort_name =
                     name
                     |> String.normalize(:nfd)
                     |> String.replace(~r/\p{M}/u, "")
                     |> String.downcase()

                   {sort_name, code}
                 end)
  @to_ash_enum_values Enum.map(@codes_by_name, fn {code, name} -> {code, [label: name]} end)
  @to_select_options Enum.map(@codes_by_name, fn {code, name} -> {name, code} end)

  @type code ::
          unquote(
            @codes
            |> Enum.map(&elem(&1, 0))
            |> Enum.reverse()
            |> Enum.reduce(fn code, acc -> quote(do: unquote(code) | unquote(acc)) end)
          )

  @doc """
  Returns the English name for a given WIPO ST.3 code.

  ## Examples

      iex> WipoSt3.name(:at)
      "Austria"

      iex> WipoSt3.name(:qz)
      "Community Plant Variety Office (European Union) (CPVO)"

  """
  @spec name(code) :: String.t()
  for {code, name} <- @codes do
    def name(unquote(code)), do: unquote(name)
  end

  @doc """
  Parses a string into a WIPO ST.3 code.

  Expects the code in lower case.

  ## Examples

      iex> WipoSt3.parse_code("at")
      {:ok, :at}

      iex> WipoSt3.parse_code("qz")
      {:ok, :qz}

      iex> WipoSt3.parse_code("AT")
      {:error, :unknown_wipo_country_code}

  """
  @spec parse_code(term()) :: {:ok, code} | {:error, :unknown_wipo_country_code}
  for {code, _name} <- @codes do
    def parse_code(unquote(Atom.to_string(code))), do: {:ok, unquote(code)}
  end

  def parse_code(_input), do: {:error, :unknown_wipo_country_code}

  @doc """
  Returns the ST.3 codes with their English names as labels, as needed for Ash enums.
  Sorted by English name, A-Z.

  ## Examples

      defmodule MyApp.CountryCode do
        use Ash.Type.Enum, values: WipoSt3.to_ash_enum_values()
      end

  """
  @spec to_ash_enum_values() :: [{code, [{:label, String.t()}]}]
  def to_ash_enum_values, do: @to_ash_enum_values

  @doc """
  Returns the ST.3 codes as `{label, value}` as needed for `Phoenix.HTML.Form.options_for_select/3`.
  Sorted by English name, A-Z.

  Run the string codes through `parse_code/1` to turn them back into atoms.

  ## Examples

      options_for_select(WipoSt3.to_select_options(), @selected_code)

  """
  @spec to_select_options() :: [{String.t(), code}]
  def to_select_options, do: @to_select_options
end
