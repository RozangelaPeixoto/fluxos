# FluxOS

## Descrição
O **FluxOS** é um sistema completo e moderno para gerenciamento de Ordens de Serviço (OS). Desenvolvido com foco na experiência do usuário e eficiência, o aplicativo permite que assistências técnicas, oficinas e prestadores de serviços gerenciem seu fluxo de trabalho de ponta a ponta, acompanhando desde o cadastro de clientes e equipamentos até o acompanhamento em tempo real do status das manutenções, desempenho dos técnicos e faturamento.

## Objetivos
- Centralizar a gestão de manutenções e atendimentos em uma única plataforma.
- Fornecer métricas claras e visuais sobre o volume de trabalho, ordens críticas (atrasadas/urgentes) e produtividade da equipe.
- Agilizar o processo de criação de Ordens de Serviço, com histórico de transição de status e anexos de evidências (fotos).
- Eliminar o uso de papel, garantindo que o histórico do cliente e do equipamento esteja sempre a um clique de distância.

## Funcionalidades
- **Dashboard Interativo:** Visão geral com indicadores de ordens abertas, concluídas, atrasadas, faturamento total e listagens de atenção imediata.
- **Gestão de Clientes e Equipamentos:** Cadastro completo com histórico de vínculos.
- **Gestão de Técnicos:** Perfil detalhado com cálculo automático de desempenho (Taxa de Resolução), faturamento gerado e controle de carga de trabalho.
- **Ordens de Serviço Avançadas:**
  - Fluxo de status inteligente (Aberta, Atribuída, Em atendimento, Aguardando peça, Concluída, Cancelada).
  - Linha do tempo (Histórico da OS) que registra a data e hora de cada etapa.
  - Alertas automáticos visuais para prazos vencidos.
  - Resumo financeiro (Mão de obra + Peças - Descontos).

## Tecnologias
- **[Flutter](https://flutter.dev/) & Dart:** Framework principal para desenvolvimento multiplataforma.
- **[Provider](https://pub.dev/packages/provider):** Gerenciamento de estado reativo e eficiente.
- **[SQLite](https://pub.dev/packages/sqflite):** Banco de dados local seguro (suporte a desktop via sqflite_common_ffi).
- **[Intl](https://pub.dev/packages/intl):** Internacionalização e formatação de datas/moedas no padrão brasileiro (pt_BR).

## Instruções para configuração e execução

### Pré-requisitos
- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado e configurado na sua máquina (versão 3.13+).
- IDE recomendada: Visual Studio Code ou Android Studio.
- (Opcional) Ambiente configurado para compilação Desktop (Windows/Linux/macOS) caso deseje rodar a versão nativa para computador.

### Rodando o projeto
1. Clone o repositório para a sua máquina local:
   `
   git clone <URL_DO_REPOSITORIO>
   `
2. Acesse o diretório do projeto:
   `
   cd FluxOS
   `
3. Instale as dependências do Flutter:
   `
   flutter pub get
   `
4. Execute o aplicativo (selecione o dispositivo Desktop ou Emulador desejado):
   `
   flutter run
   `

> **Nota para Desktop:** O FluxOS já vem configurado para abrir em formato de janela responsiva no Windows, trazendo uma experiência unificada.
