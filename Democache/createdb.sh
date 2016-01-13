#!/bin/sh

ess server reset

ess create database climate --ports=10015

ess create table table1 s,pkey:artificial S:col_1 S:col_2 S:col_3 S:col_4 F:col_5 I:col_6 F:col_7 I:col_8 F:col_9 I:col_10 F:col_11 I:col_12 F:col_13 I:col_14 F:col_15 I:col_16 F:col_17 F:col_18 F:col_19 S:col_20 F:col_21 S:col_22 F:col_23 S:col_24 F:col_25 S:col_26
ess create table table2 s,pkey:artificial S:col_1 S:col_2 S:col_3 S:col_4 F:col_5 I:col_6 F:col_7 I:col_8 F:col_9 I:col_10 F:col_11 I:col_12 F:col_13 I:col_14 F:col_15 I:col_16 F:col_17 F:col_18 F:col_19 S:col_20 F:col_21 S:col_22 F:col_23 S:col_24 F:col_25 S:col_26
ess create table table3 s,pkey:artificial S:col_1 S:col_2 S:col_3 S:col_4 F:col_5 I:col_6 F:col_7 I:col_8 F:col_9 I:col_10 F:col_11 I:col_12 F:col_13 I:col_14 F:col_15 I:col_16 F:col_17 F:col_18 F:col_19 S:col_20 F:col_21 S:col_22 F:col_23 S:col_24 F:col_25 S:col_26
ess create table table4 s,pkey:artificial S:col_1 S:col_2 S:col_3 S:col_4 F:col_5 I:col_6 F:col_7 I:col_8 F:col_9 I:col_10 F:col_11 I:col_12 F:col_13 I:col_14 F:col_15 I:col_16 F:col_17 F:col_18 F:col_19 S:col_20 F:col_21 S:col_22 F:col_23 S:col_24 F:col_25 S:col_26
ess create table table5 s,pkey:artificial S:col_1 S:col_2 S:col_3 S:col_4 F:col_5 I:col_6 F:col_7 I:col_8 F:col_9 I:col_10 F:col_11 I:col_12 F:col_13 I:col_14 F:col_15 I:col_16 F:col_17 F:col_18 F:col_19 S:col_20 F:col_21 S:col_22 F:col_23 S:col_24 F:col_25 S:col_26
ess create table table6 s,pkey:artificial S:col_1 S:col_2 S:col_3 S:col_4 F:col_5 I:col_6 F:col_7 I:col_8 F:col_9 I:col_10 F:col_11 I:col_12 F:col_13 I:col_14 F:col_15 I:col_16 F:col_17 F:col_18 F:col_19 S:col_20 F:col_21 S:col_22 F:col_23 S:col_24 F:col_25 S:col_26
ess create table table7 s,pkey:artificial S:col_1 S:col_2 S:col_3 S:col_4 F:col_5 I:col_6 F:col_7 I:col_8 F:col_9 I:col_10 F:col_11 I:col_12 F:col_13 I:col_14 F:col_15 I:col_16 F:col_17 F:col_18 F:col_19 S:col_20 F:col_21 S:col_22 F:col_23 S:col_24 F:col_25 S:col_26
ess create table table8 s,pkey:artificial S:col_1 S:col_2 S:col_3 S:col_4 F:col_5 I:col_6 F:col_7 I:col_8 F:col_9 I:col_10 F:col_11 I:col_12 F:col_13 I:col_14 F:col_15 I:col_16 F:col_17 F:col_18 F:col_19 S:col_20 F:col_21 S:col_22 F:col_23 S:col_24 F:col_25 S:col_26
ess create table table9 s,pkey:artificial S:col_1 S:col_2 S:col_3 S:col_4 F:col_5 I:col_6 F:col_7 I:col_8 F:col_9 I:col_10 F:col_11 I:col_12 F:col_13 I:col_14 F:col_15 I:col_16 F:col_17 F:col_18 F:col_19 S:col_20 F:col_21 S:col_22 F:col_23 S:col_24 F:col_25 S:col_26
ess create table table10 s,pkey:artificial S:col_1 S:col_2 S:col_3 S:col_4 F:col_5 I:col_6 F:col_7 I:col_8 F:col_9 I:col_10 F:col_11 I:col_12 F:col_13 I:col_14 F:col_15 I:col_16 F:col_17 F:col_18 F:col_19 S:col_20 F:col_21 S:col_22 F:col_23 S:col_24 F:col_25 S:col_26

ess server commit

ess udbd start

ess select asi-opendata
