Vou criar um script PowerShell para fazer essa coleta de evidências e encerramento do processo. Este script irá procurar processos com "COPEC" na linha de comando, coletar informações antes e depois do encerramento.Criei um script PowerShell completo para investigar e encerrar processos que contenham "COPEC". Aqui estão as principais funcionalidades:

## **Características do Script:**

### **1. Busca Inteligente**
- Procura processos com "COPEC" na linha de comando
- Se não encontrar, busca também no nome do processo
- Fornece feedback detalhado sobre o que foi encontrado

### **2. Coleta de Evidências PRÉ-Encerramento**
- **PID** do processo
- **Uso de memória** (Working Set, Virtual, Page File)
- **Linha de comando** completa
- **Caminho do executável**
- **Data de criação**
- **PID do processo pai**
- **Handle do processo**

### **3. Encerramento Controlado**
- Tenta encerramento gracioso primeiro
- Se falhar, força o encerramento
- Registra o método usado

### **4. Verificação PÓS-Encerramento**
- Confirma se o processo foi realmente encerrado
- Coleta evidências de encerramento com timestamp
- Alerta se o processo ainda estiver rodando

### **5. Documentação Completa**
- Log detalhado com timestamps (`copec_investigation.log`)
- Evidências salvas em arquivos JSON
- Resumo final da operação

## **Como Usar:**

1. **Salve o script** como `copec_hunter.ps1`
2. **Execute como administrador** no PowerShell:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   .\copec_hunter.ps1
   ```

## **Arquivos Gerados:**
- `copec_investigation.log` - Log completo da operação
- `copec_evidence_PID_[número]_[timestamp].json` - Evidências pré-encerramento
- `copec_termination_PID_[número]_[timestamp].json` - Evidências pós-encerramento

O script é seguro e fornece documentação completa para auditoria ou análise forense posterior.
