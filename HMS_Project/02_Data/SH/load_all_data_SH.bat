@echo off
echo =======================================================
echo Loading Data for Shaswin (SH)
echo Target DB: apps/apps@//150.136.96.10:1521/ebs_ebsdb
echo =======================================================

echo Loading HMS_HOSPITAL_MASTER_SH...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_HOSPITAL_MASTER_SH.ctl log=HMS_HOSPITAL_MASTER_SH.log

echo Loading HMS_BRANCH_SH...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_BRANCH_SH.ctl log=HMS_BRANCH_SH.log

echo Loading HMS_DEPT_SH...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_DEPT_SH.ctl log=HMS_DEPT_SH.log

echo Loading HMS_EMPLOYEE_SH...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_EMPLOYEE_SH.ctl log=HMS_EMPLOYEE_SH.log

echo Loading HMS_EMP_PHONE_SH...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_EMP_PHONE_SH.ctl log=HMS_EMP_PHONE_SH.log

echo Loading HMS_DOC_AVAIL_SH...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_DOC_AVAIL_SH.ctl log=HMS_DOC_AVAIL_SH.log

echo Loading HMS_PATIENT_SH...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_PATIENT_SH.ctl log=HMS_PATIENT_SH.log

echo All loads completed. Please review the .log files for any discarded/bad rows.
pause
