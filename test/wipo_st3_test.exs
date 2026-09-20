defmodule WipoSt3Test do
  use ExUnit.Case, async: true

  doctest WipoSt3

  describe "name/1" do
    test "returns the English name of a code" do
      assert WipoSt3.name(:at) == "Austria"
      assert WipoSt3.name(:qz) == "Community Plant Variety Office (European Union) (CPVO)"
    end

    test "keeps accented names intact" do
      assert WipoSt3.name(:ci) == "Côte d’Ivoire"
    end

    test "does not match codes outside of ST.3" do
      # Slip the invalid country code past the type checker
      unknown_code = String.to_atom("zz")
      assert_raise FunctionClauseError, fn -> WipoSt3.name(unknown_code) end
    end
  end

  describe "parse_code/1" do
    test "turns an ST.3 string into the matching code" do
      assert WipoSt3.parse_code("at") == {:ok, :at}
      assert WipoSt3.parse_code("qz") == {:ok, :qz}
    end

    test "accepts every code of the dataset" do
      for {code, _label} <- WipoSt3.to_ash_enum_values() do
        assert WipoSt3.parse_code(Atom.to_string(code)) == {:ok, code}
      end
    end

    test "is sensitive to case and whitespace" do
      assert WipoSt3.parse_code("AT") == {:error, :unknown_wipo_country_code}
      assert WipoSt3.parse_code(" at ") == {:error, :unknown_wipo_country_code}
    end

    test "reports anything else as an unknown code" do
      assert WipoSt3.parse_code("zz") == {:error, :unknown_wipo_country_code}
      assert WipoSt3.parse_code("") == {:error, :unknown_wipo_country_code}
      assert WipoSt3.parse_code("abc") == {:error, :unknown_wipo_country_code}
      assert WipoSt3.parse_code(nil) == {:error, :unknown_wipo_country_code}
      assert WipoSt3.parse_code(:at) == {:error, :unknown_wipo_country_code}
    end
  end

  describe "to_ash_enum_values/0" do
    test "returns codes and names as labels for Ash.Type.Enum" do
      values = WipoSt3.to_ash_enum_values()

      assert Keyword.keyword?(values)
      assert Keyword.fetch!(values, :at) == [label: "Austria"]

      assert Keyword.fetch!(values, :qz) == [
               label: "Community Plant Variety Office (European Union) (CPVO)"
             ]
    end

    test "covers every entry of the dataset" do
      assert length(WipoSt3.to_ash_enum_values()) == dataset_size()
    end
  end

  describe "to_select_options/0" do
    test "returns {label, value} pairs for options_for_select/3" do
      options = WipoSt3.to_select_options()

      assert {"Austria", :at} in options
      assert Enum.all?(options, fn {label, code} -> is_binary(label) and is_atom(code) end)
    end
  end

  describe "the generated code table" do
    test "the code/0 type covers every code of the dataset" do
      {:ok, types} = Code.Typespec.fetch_types(WipoSt3)

      {:type, {_name, {:type, _meta, :union, members}, _args}} =
        Enum.find(types, fn
          {:type, {_, {:type, _, :union, _}, _}} -> true
          _ -> false
        end)

      codes = members |> Enum.map(fn {:atom, _, code} -> code end) |> Enum.sort()

      assert codes == Enum.sort(Keyword.keys(WipoSt3.to_ash_enum_values()))
      assert length(codes) == dataset_size()
    end
  end

  defp dataset_size do
    [__DIR__, "..", "priv", "wipo_st3_codes.json"]
    |> Path.join()
    |> Path.expand()
    |> File.read!()
    |> JSON.decode!()
    |> length()
  end
end
