@echo off
echo =======================================================
echo Loading Data for Namitha (NM)
echo Target DB: apps/apps@//150.136.96.10:1521/ebs_ebsdb
echo =======================================================

echo Loading HMS_HOSPITAL_MASTER_NM...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_HOSPITAL_MASTER_NM.ctl log=HMS_HOSPITAL_MASTER_NM.log

echo Loading HMS_BRANCH_NM...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_BRANCH_NM.ctl log=HMS_BRANCH_NM.log

echo Loading HMS_DEPT_NM...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_DEPT_NM.ctl log=HMS_DEPT_NM.log

echo Loading HMS_EMPLOYEE_NM...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_EMPLOYEE_NM.ctl log=HMS_EMPLOYEE_NM.log

echo Loading HMS_EMP_PHONE_NM...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_EMP_PHONE_NM.ctl log=HMS_EMP_PHONE_NM.log

echo Loading HMS_DOC_AVAIL_NM...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_DOC_AVAIL_NM.ctl log=HMS_DOC_AVAIL_NM.log

echo Loading HMS_PATIENT_NM...
sqlldr apps/apps@//150.136.96.10:1521/ebs_ebsdb control=HMS_PATIENT_NM.ctl log=HMS_PATIENT_NM.log

echo All loads completed. Please review the .log files for any discarded/bad rows.
pause
