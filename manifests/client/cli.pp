# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include mssql::client::cli
class mssql::client::cli (
  Enum[
    'Microsoft Command Line Utilities 14 for SQL Server',
    'Microsoft Command Line Utilities 15 for SQL Server'
  ] $cliname = 'Microsoft Command Line Utilities 15 for SQL Server',
  String $clisource = 'c:/temp/MsSqlCmdLnUtils.msi',
  String $cliensure = $mssql::client::ensure,
) {
  include ::mssql::client::cli::install
}
