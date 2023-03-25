defmodule Wmcgy.TransactionImport.ImportProgress do
  @moduledoc """
  Module to track import progress
  """
  alias Wmcgy.TransactionImport.ImportError

  @type t :: %__MODULE__{
          new_record_count: pos_integer(),
          updated_record_count: pos_integer(),
          duplicate_record_count: pos_integer(),
          error_count: pos_integer(),
          errors: list(ImportError.t()),
          invalid_file?: boolean(),
          current_row: pos_integer()
        }
  defstruct new_record_count: 0,
            updated_record_count: 0,
            duplicate_record_count: 0,
            error_count: 0,
            errors: [],
            invalid_file?: false,
            current_row: 1

  def handle_event({:ok, :created}, import_progress) do
    %{
      import_progress
      | new_record_count: import_progress.new_record_count + 1,
        current_row: import_progress.current_row + 1
    }
  end

  def handle_event({:ok, :updated}, import_progress) do
    %{
      import_progress
      | updated_record_count: import_progress.updated_record_count + 1,
        current_row: import_progress.current_row + 1
    }
  end

  def handle_event({:ok, :noop}, import_progress) do
    %{
      import_progress
      | duplicate_record_count: import_progress.duplicate_record_count + 1,
        current_row: import_progress.current_row + 1
    }
  end

  def handle_event({:error, error_changeset}, import_progress) do
    current_row = import_progress.current_row + 1

    %{
      import_progress
      | error_count: import_progress.error_count + 1,
        errors: import_progress.errors ++ [ImportError.new(error_changeset, current_row)],
        current_row: current_row
    }
  end
end
