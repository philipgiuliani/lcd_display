defmodule LcdDisplay do
  @moduledoc """
  A collection of utility functions to use this library.
  """

  @type display_driver :: LcdDisplay.HD44780.Driver.t()
  @type display_command :: LcdDisplay.HD44780.Driver.command()
  @type config :: %{
          required(:driver_module) => atom,
          atom => any
        }

  @doc """
  Returns a specification to start this module under a supervisor.
  """
  @spec child_spec(config, GenServer.options()) :: Supervisor.child_spec()
  def child_spec(config, opts \\ []) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [config, opts]}
    }
  end

  @doc """
  Starts a display controller process for a specified.
  """
  @spec start_link(config, GenServer.options()) :: {:ok, pid} | {:error, any}
  def start_link(config, opts \\ []) when is_map(config) do
    {%{driver_module: driver_module}, other_config} = Map.split(config, [:driver_module])
    display = initialize_display(driver_module, other_config)
    LcdDisplay.DisplayController.start_link(display, opts)
  end

  @doc """
  Executes a supported command.
  """
  @spec execute(GenServer.server(), display_command) :: {:ok, display_driver} | {:error, any}
  def execute(server, command) do
    LcdDisplay.DisplayController.execute(server, command)
  end

  @spec initialize_display(atom, map) :: {:ok, display_driver} | {:error, any}
  defp initialize_display(driver_module, config) when is_atom(driver_module) and is_map(config) do
    case driver_module.start(config) do
      {:ok, display} -> display
      {:error, reason} -> {:error, reason}
    end
  end
end
