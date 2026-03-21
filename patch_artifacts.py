import os

BRAIN_DIR = r'C:\Users\Admin\.gemini\antigravity\brain\0b171063-4b27-4584-89e0-8a6f0496144d'
task_file = os.path.join(BRAIN_DIR, 'task.md')
impl_file = os.path.join(BRAIN_DIR, 'implementation_plan.md')

if os.path.exists(task_file):
    with open(task_file, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace(
        '- [ ] **Run** SQL*Loader commands for each table in each member\'s folder (see GUI guide)',
        '- [x] Single-click batch scripts created (`load_all_data_<SUFFIX>.bat`) to automate all 7 `sqlldr` executions for each member targeting external DB.'
    )
    with open(task_file, 'w', encoding='utf-8') as f:
        f.write(content)

if os.path.exists(impl_file):
    with open(impl_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    import re
    # We will replace the entire SQL loader block
    pattern = re.compile(r'2\. Run SQL\*Loader for each of your components:\s+```bash.*?```', re.DOTALL)
    
    new_text = "2. Directly execute your personalized double-click batch file: `load_all_data_<SUFFIX>.bat`. This securely runs `sqlldr` via `apps/apps@//150.136.96.10:1521/ebs_ebsdb` across all 7 Control tables flawlessly."
    
    content = pattern.sub(new_text, content)
    
    with open(impl_file, 'w', encoding='utf-8') as f:
        f.write(content)

print('Artifacts updated.')
