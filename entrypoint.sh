#!/bin/sh

echo "Start Testing"
echo "Requirements path : $1"
echo "DAGs directory : $2"
echo "Variable path : $3"
echo "Connections path : $4"
echo "Plugin directory : $5"
echo "Load examples : $6"

pip install -r $1

export AIRFLOW__CORE__LOAD_DEFAULT_CONNECTIONS="False"

airflow db init
airflow variables import $3
airflow connections import $4


cp -r /action/* /github/workspace/

echo $PYTHONPATH
export PYTHONPATH="${PYTHONPATH:+${PYTHONPATH}:}${PWD}/$2"
echo $PYTHONPATH
export AIRFLOW__CORE__PLUGINS_FOLDER="${PWD}/$5"
export AIRFLOW__CORE__LOAD_EXAMPLES="$6"

echo "\nList Variables :" >> result.log
airflow variables list >> result.log
echo "\nList Connections :" >> result.log
airflow connections list >> result.log
echo "\nList Plugins :" >> result.log
airflow plugins >> result.log

pytest dag_validation.py -s -q >> result.log
pytest_exit_code=`echo Pytest exited $?`
echo $pytest_exit_code
python alert.py --log_filename=result.log --repo_token=$7
if [ "$pytest_exit_code" != "Pytest exited 0" ]; then echo "Pytest did not exit 0" ;fi
if [ "$pytest_exit_code" != "Pytest exited 0" ]; then exit 1 ;fi