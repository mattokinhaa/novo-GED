
const express = require('express');
const faker = require('faker');
const cors = require('cors');
const app = express();

// Configurações
app.use(cors());
app.use(express.json());

// Dados Fakes (Simulando o banco de dados)
let auditores = [];
let usuarios = [];
let empresas = [];
let funcionarios = [];
let certificacoes = [];

// Função para gerar dados falsos
const gerarDados = () => {
    // Gerar dados para auditores
    for (let i = 0; i < 10; i++) {
        auditores.push({
            id_auditor: i + 1,
            nome: faker.name.findName(),
            email: faker.internet.email(),
            cpf: faker.random.replace(/[0-9]{11}/, '###########'),
            senha: faker.internet.password(),
            departamento: faker.commerce.department(),
            criado_em: faker.date.past(),
            atualizado_em: faker.date.recent()
        });
    }

    // Gerar dados para empresas
    for (let i = 0; i < 5; i++) {
        empresas.push({
            id_empresa: i + 1,
            nome: faker.company.companyName(),
            cnpj: faker.random.replace(/[0-9]{14}/, '##############'),
            programa_gerenciamento_risco: faker.lorem.sentence(),
            pcmso: faker.lorem.sentence(),
            controle_seguranca: faker.lorem.sentence(),
            endereco: faker.address.streetAddress(),
            email: faker.internet.email(),
            telefone: faker.phone.phoneNumber(),
            criado_em: faker.date.past(),
            atualizado_em: faker.date.recent()
        });
    }

    // Gerar dados para funcionários
    for (let i = 0; i < 15; i++) {
        funcionarios.push({
            id_funcionario: i + 1,
            nome: faker.name.findName(),
            cpf: faker.random.replace(/[0-9]{11}/, '###########'),
            funcao: faker.name.jobTitle(),
            aso: faker.date.past(),
            contratado: faker.random.boolean(),
            possui_treinamento: faker.random.boolean(),
            possui_documentos: faker.random.boolean(),
            possui_epi: faker.random.boolean(),
            foto: faker.image.avatar(),
            id_empresa: faker.random.number({ min: 1, max: 5 }),
            criado_em: faker.date.past(),
            atualizado_em: faker.date.recent()
        });
    }

    // Gerar dados para certificações
    for (let i = 0; i < 15; i++) {
        certificacoes.push({
            id_certificacao: i + 1,
            nr_os: faker.date.past(),
            nr_06: faker.date.past(),
            nr_10: faker.date.past(),
            nr_11: faker.date.past(),
            nr_12: faker.date.past(),
            nr_13: faker.date.past(),
            nr_17: faker.date.past(),
            nr_18: faker.date.past(),
            nr_20: faker.date.past(),
            nr_33: faker.date.past(),
            id_funcionario: i + 1,
            criado_em: faker.date.past(),
            atualizado_em: faker.date.recent()
        });
    }
};

// Rota para obter todos os auditores
app.get('/api/auditores', (req, res) => {
    res.json(auditores);
});

// Rota para criar um auditor
app.post('/api/auditores', (req, res) => {
    const { nome, email, cpf, senha, departamento } = req.body;
    const novoAuditor = {
        id_auditor: auditores.length + 1,
        nome,
        email,
        cpf,
        senha,
        departamento,
        criado_em: new Date(),
        atualizado_em: new Date()
    };
    auditores.push(novoAuditor);
    res.status(201).json(novoAuditor);
});

// Rota para obter todos os usuários
app.get('/api/usuarios', (req, res) => {
    res.json(usuarios);
});

// Rota para criar um usuário
app.post('/api/usuarios', (req, res) => {
    const { nome, email, cpf, senha, id_empresa } = req.body;
    const novoUsuario = {
        id_usuario: usuarios.length + 1,
        nome,
        email,
        cpf,
        senha,
        id_empresa,
        criado_em: new Date(),
        atualizado_em: new Date()
    };
    usuarios.push(novoUsuario);
    res.status(201).json(novoUsuario);
});

// Rota para obter todas as empresas
app.get('/api/empresas', (req, res) => {
    res.json(empresas);
});

// Rota para criar uma empresa
app.post('/api/empresas', (req, res) => {
    const { nome, cnpj, programa_gerenciamento_risco, pcmso, controle_seguranca, endereco, email, telefone } = req.body;
    const novaEmpresa = {
        id_empresa: empresas.length + 1,
        nome,
        cnpj,
        programa_gerenciamento_risco,
        pcmso,
        controle_seguranca,
        endereco,
        email,
        telefone,
        criado_em: new Date(),
        atualizado_em: new Date()
    };
    empresas.push(novaEmpresa);
    res.status(201).json(novaEmpresa);
});

// Rota para obter todos os funcionários
app.get('/api/funcionarios', (req, res) => {
    res.json(funcionarios);
});

// Rota para criar um funcionário
app.post('/api/funcionarios', (req, res) => {
    const { nome, cpf, funcao, aso, contratado, possui_treinamento, possui_documentos, possui_epi, foto, id_empresa } = req.body;
    const novoFuncionario = {
        id_funcionario: funcionarios.length + 1,
        nome,
        cpf,
        funcao,
        aso,
        contratado,
        possui_treinamento,
        possui_documentos,
        possui_epi,
        foto,
        id_empresa,
        criado_em: new Date(),
        atualizado_em: new Date()
    };
    funcionarios.push(novoFuncionario);
    res.status(201).json(novoFuncionario);
});

// Rota para obter todas as certificações
app.get('/api/certificacoes', (req, res) => {
    res.json(certificacoes);
});

// Rota para criar uma certificação
app.post('/api/certificacoes', (req, res) => {
    const { nr_os, nr_06, nr_10, nr_11, nr_12, nr_13, nr_17, nr_18, nr_20, nr_33, id_funcionario } = req.body;
    const novaCertificacao = {
        id_certificacao: certificacoes.length + 1,
        nr_os,
        nr_06,
        nr_10,
        nr_11,
        nr_12,
        nr_13,
        nr_17,
        nr_18,
        nr_20,
        nr_33,
        id_funcionario,
        criado_em: new Date(),
        atualizado_em: new Date()
    };
    certificacoes.push(novaCertificacao);
    res.status(201).json(novaCertificacao);
});

// Inicializa os dados falsos
gerarDados();

// Inicializando o servidor
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Fake API rodando na porta ${PORT}`);
});
