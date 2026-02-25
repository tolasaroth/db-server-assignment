# Secure PostgreSQL 16 Deployment (Ubuntu 24.04.3 LTS)

[cite_start]This repository contains the implementation of a hardened, enterprise-grade database server based on the **DB Server Assignment Scope v2**[cite: 1, 22].

## 📌 Project Overview
[cite_start]The project involves provisioning and securing a **PostgreSQL 16.x** environment on **Ubuntu Server 24.04.3 LTS**[cite: 4, 8]. [cite_start]The goal is to establish a high-security infrastructure featuring intrusion prevention, role-based access control (RBAC), and robust disaster recovery[cite: 52, 101, 186].

## 🛠 Tech Stack
* [cite_start]**OS:** Ubuntu Server 24.04.3 LTS [cite: 15]
* [cite_start]**Database:** PostgreSQL 16.x [cite: 8]
* [cite_start]**Management:** pgAdmin 4 [cite: 9]
* [cite_start]**Security:** UFW, Fail2ban, AIDE, and SSL/TLS [cite: 42, 52, 57, 85]
* [cite_start]**Monitoring:** pg_stat_statements & pgBadger [cite: 10]

## 🛡 Key Security Implementations
* [cite_start]**System Hardening:** SSH key-based authentication, disabled root login, and custom SSH ports[cite: 33, 34, 36].
* [cite_start]**Network Security:** "Default Deny" firewall policy and IP-restricted database access[cite: 43, 81].
* [cite_start]**Database Security:** SCRAM-SHA-256 password encryption and Row-Level Security (RLS) policies[cite: 78, 138].
* [cite_start]**Audit & Compliance:** Detailed logging of DDL and data modifications via `pgaudit`[cite: 144, 146, 149].

## 💾 Backup & Recovery
* [cite_start]Automated daily full backups with 30-day retention[cite: 188, 191].
* [cite_start]Write-Ahead Log (WAL) archiving for Point-in-Time Recovery (PITR)[cite: 190, 208].

## 👥 Team
[cite_start]This project was executed by a 7-member team specialized in Infrastructure, DBA, Security, and Backup/Recovery[cite: 223].