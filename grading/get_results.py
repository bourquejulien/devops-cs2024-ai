#!/bin/env python3

import os
import csv
import sys
from typing import Iterable
from azure.data.tables import TableServiceClient
from azure.cli.core import get_default_cli
from pathlib import Path
from os import path

def az_cli (*args_str: str) -> dict:
    args = " ".join(args_str).split()
    cli = get_default_cli()
    cli.invoke(args, out_file=open(os.devnull, 'w'))
    if cli.result.result:
        return cli.result.result
    elif cli.result.error:
        raise cli.result.error
    return True

def get_teams() -> str:
    response = az_cli("group list")
    teams = [rg["name"].split("-")[1] for rg in response if rg["name"].split("-")[0] == "CS"]
    return teams

def get_table_string(id: str, rg_name: str):
    table_name = f"ta{id}"
    response = az_cli(f"storage account show-connection-string --name {table_name} --resource-group {rg_name}")
    return response["connectionString"]

def get_random_id() -> str:
    response = az_cli("acr list --resource-group Global-rg")
    id = response[0]["name"]
    return id

def get_table_data(table_name: str, table_account: TableServiceClient) -> Iterable[list[str]]:
    with table_account.get_table_client(table_name) as table:
        for row in table.list_entities():
            timestamp = row.metadata["timestamp"]
            yield [table_name, timestamp, row["StepName"], row["IsSuccess"]]

def get_tables_data(table_account: TableServiceClient) -> Iterable[list[str]]:
    table_names = [table.name for table in table_account.list_tables()]
    for table_name in table_names:
        for row in get_table_data(table_name, table_account):
            yield row
    
def write_csv(file_name: str, rows: Iterable[list[str]]):
    FOLDER_NAME = "results"
    Path(FOLDER_NAME).mkdir(parents=True, exist_ok=True)

    file_path = path.join(FOLDER_NAME, file_name)
    field = ["table_name", "timestamp", "step_name", "is_success"]

    with open(file_path, "w", newline='') as f:
        writer = csv.writer(f, delimiter=',')
        writer.writerow(field)

        for row in rows:
            writer.writerow(row)

def backup_tables():
    csv_name = f"{sys.argv[1]}.csv"

    id = get_random_id()
    table_string = get_table_string(id, "Global-rg")
    rows = []

    with TableServiceClient.from_connection_string(table_string) as table_account:
        rows = get_tables_data(table_account)
        write_csv(csv_name, rows)

if __name__ == "__main__":
    backup_tables()
