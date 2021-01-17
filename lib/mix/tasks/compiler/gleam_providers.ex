defmodule Mix.Tasks.Compile.GleamProviders do
  use Mix.Task.Compiler

  def run(_args) do
    providers = load_all()

    for provider <- providers do
      extension = provider.extension()
      root = File.cwd!()

      Path.wildcard(root <> "/src/**/*" <> extension)
      |> Enum.each(fn file ->
        contents =
          File.read!(file)
          |> provider.provide()

        File.write(String.replace(file, extension, ".gleam"), contents)
      end)
    end
    :ok
  end

  # https://github.com/elixir-lang/elixir/blob/1000780a75867fcdba20f91a21bd64eb613c9ad3/lib/mix/lib/mix/task.ex#L157
  @doc """
  Loads all providers in all code paths.
  """
  def load_all, do: load_providers(:code.get_path())

  @doc """
  Loads all providers in the given `paths`.
  """
  def load_providers(dirs) do
    # We may get duplicate modules because we look through the
    # entire load path so make sure we only return unique modules.
    for dir <- dirs,
        file <- safe_list_dir(to_charlist(dir)),
        module = provider_from_path(file),
        uniq: true,
        do: module
  end

  defp safe_list_dir(path) do
    case File.ls(path) do
      {:ok, paths} -> paths
      {:error, _} -> []
    end
  end

  @prefix_size byte_size("gleam@providers@")
  @suffix_size byte_size(".beam")

  defp provider_from_path(filename) do
    base = Path.basename(filename)
    part = byte_size(base) - @prefix_size - @suffix_size

    case base do
      <<"gleam@providers@", rest::binary-size(part), ".beam">> ->
        module = :"gleam@providers@#{rest}"
        Code.ensure_loaded?(module) && module

      _ ->
        nil
    end
  end
end
