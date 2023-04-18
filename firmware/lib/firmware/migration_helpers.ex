defmodule Firmware.MigrationHelpers do
  @moduledoc """
  API for easily running Ecto migrations inside a release.

  ## Examples

      iex> Firmware.MigrationHelpers.migrate
  """
  @app :ui

  def migrate() do
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos() do
    _ = Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end
end
