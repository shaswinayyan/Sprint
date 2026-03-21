@echo off
echo =======================================================
echo Loading Data for Chandana (CH)
echo Target DB: apps/apps@//150.136.96.10:1521/ebs_ebsdb
echo =======================================================

echo Loading HMS_HOSPITAL_MASTER_CH...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_HOSPITAL_MASTER_CH.ctl log=HMS_HOSPITAL_MASTER_CH.log

echo Loading HMS_BRANCH_CH...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_BRANCH_CH.ctl log=HMS_BRANCH_CH.log

echo Loading HMS_DEPT_CH...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_DEPT_CH.ctl log=HMS_DEPT_CH.log

echo Loading HMS_EMPLOYEE_CH...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_EMPLOYEE_CH.ctl log=HMS_EMPLOYEE_CH.log

echo Loading HMS_EMP_PHONE_CH...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_EMP_PHONE_CH.ctl log=HMS_EMP_PHONE_CH.log

echo Loading HMS_DOC_AVAIL_CH...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_DOC_AVAIL_CH.ctl log=HMS_DOC_AVAIL_CH.log

echo Loading HMS_PATIENT_CH...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_PATIENT_CH.ctl log=HMS_PATIENT_CH.log

echo All loads completed. Please review the .log files for any discarded/bad rows.
pause
