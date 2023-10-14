# TensorFlow ≥2.0 is required
import tensorflow as tf
from tensorflow import keras
from keras import Sequential
from keras.layers import Dense
from keras.layers import Input
from keras.optimizers import Adam
assert tf.__version__ >= "2.0"

# Common imports
import numpy as np
import random
from collections import deque
import os
import pickle
import shutil

class DQN:
    def __init__(self, env, load_model=False, save_memory=False):
        self.action_space = env.action_space.shape[0] # quantidade de ações
        self.state_space = env.state_space.shape[0] # quantidade de estados
        self.gamma = .95 # taxa de desconto
        self.batch_size = 500 # tamanho do lote
        self.epsilon = 0 if load_model else 1 # epsilon
        self.epsilon_min = .05 # epsilon minimo
        self.epsilon_decay = .995 # epsilon decadência
        self.learning_rate = 0.001 # taxa de aprendizado
        self.layer_hsize = int(((2/3) * self.state_space) + self.action_space) # calculo de neuronio das camadas
        self.layer_sizes = [self.state_space, self.layer_hsize, self.layer_hsize ] # vetor de tamanho das camadas
        self.memory = deque(maxlen=200000) # memoria maxima para aprendizado
        self.history = self.get_history_list('dqn', load_model, save_memory) # carregar historico de treinamento/evolução
        self.model = self.build_model(load_model) # carregar modelo
        
        # preenche a memoria com os dados historicos
        if (len(self.history['memory_history'])>0):
            for i in range(len(self.history['memory_history'])):
                self.memory.append(self.history['memory_history'][i])
                
        # mostrar o tamanho do vetor memoria
        print('load memory len -> ({})'.format(len(self.history['memory_history'])))
    

    # criar ou carregar modelo da rede neural
    def build_model(self, load_model):
        
        # carregar modelo existente
        if load_model:
            model = tf.keras.models.load_model("dqn/perseguidor.keras")
            return model
        # criar novo modelo
        else:
            # se existir modelo, realizar a exclusão
            try:
                shutil.rmtree('dqn/perseguidor.keras')
                #os.remove("dqn/perseguidor.h5")
            except:
                print("Não existe arquivos e diretorio para exclusão")

            # criação do modelo
            model = Sequential()

            # adicionar as camadas
            for i in range(len(self.layer_sizes)):
                if i == 0:
                    # camada de entrada
                    model.add(Dense(self.layer_sizes[i], activation='relu', input_shape=(self.state_space,)))
                else:
                    # camada oculta
                    model.add(Dense(self.layer_sizes[i], activation='relu'))
            # camada de saida
            model.add(Dense(self.action_space, activation='linear'))
            # compilar modelo com otimizador Adam com taxa de aprendizado definida, função de perda e acuracia
            model.compile(keras.optimizers.Adam(learning_rate=self.learning_rate),loss='mse',metrics=['accuracy']) #loss='categorical_crossentropy'
            return model

    # salvar passo/step na memoria
    def remember(self, state, action, reward, next_state, done):
        self.memory.append((state, action, reward, next_state, done))
        self.history['memory_history'].append((state, action, reward, next_state, done))

    # ação/predição do modelo
    def act(self, state, load_model):
        # predição do modelo de acordo com estado enviado
        act_values = self.model(state)

        # se for um modelo carregado retornar predição do mesmo
        if (load_model):
            return np.argmax(act_values[0])
        # se não avaliar, iniciar com random até atingir a taxa de epsilon
        else:
            if np.random.rand() <= self.epsilon:
                return np.argmax(np.random.randint(0,2,4))
            return np.argmax(act_values[0])

    # treinamento do modelo
    def replay(self):
        # verifica se a memoria ja contem o lote necessario para treinamento
        if len(self.memory) < self.batch_size:
            return
        
        minibatch = random.sample(self.memory, self.batch_size) # novo array aleatorio da memoria respeitando o tamanho do lote para treinamento
        states = np.array([i[0] for i in minibatch]) # lote de estados
        actions = np.array([i[1] for i in minibatch]) # lote de ações
        rewards = np.array([i[2] for i in minibatch]) # lote de recompensas
        next_states = np.array([i[3] for i in minibatch]) # lote do proximo estado
        dones = np.array([i[4] for i in minibatch]) # lote de finalização do jogo

        states = np.squeeze(states) # removendo dimensões/shape com tamanho 1 dos estados
        next_states = np.squeeze(next_states) # removendo dimensões/shape com tamanho 1 dos proximos estados

        # equação de bellman para obter o novo valor de Q para estado e ação
        targets = rewards + self.gamma*(np.amax(self.model.predict_on_batch(next_states), axis=1))*(1-dones)

        
        targets_full = self.model.predict_on_batch(states) # lote de predição dos estados enviados
        ind = np.array([i for i in range(self.batch_size)]) # conversão para array
        targets_full[[ind], [actions]] = targets # define o novo valor Q para o lote preditado
        

        loss = self.model.train_on_batch(states, targets_full) # realiza o treinamento em lote e retorna as metricas 
        self.history['loss_history'].append(loss[0]) # perda
        self.history['acc_history'].append(loss[1]) # acuracia

        #loss = self.model.fit(states, targets_full, epochs=1, verbose=2) # realiza o treinamento em lote e retorna as metricas
        #self.history['loss_history'].append(loss.history['loss'][0]) # perda   
        #self.history['acc_history'].append(loss.history['accuracy'][0]) # acuracia

        # se epsilon for maior que o minimo aplicar decadencia
        if self.epsilon > self.epsilon_min:
            self.epsilon *= self.epsilon_decay


    # função para gravar dados no arquivo
    def write_list(self, name, data):
        with open(name, 'wb') as filehandle:
            pickle.dump(data, filehandle)
            filehandle.close()
            
    # função para ler dados em arquivos
    def read_list(self,name):
        data = []
        with open(name, 'rb') as filehandle:
            data = pickle.load(filehandle)
            filehandle.close()
        return data

    # carregar ou criar vetores/matrizes de historicos e treinamentos
    def get_history_list(self, algorithm, load_model, save_memory):
        history = dict()
        history['ep_reward'] = []
        history['avg_reward'] = []
        history['obs_history'] = []
        history['action_history'] = []
        history['reward_history'] = []
        history['loss_history'] = []
        history['acc_history'] = []
        history['memory_history'] = []
        history['seconds_history'] = []
        history['score_history'] = []
        for l in history:
            filename = f'{algorithm}/{l}.dat'
            if load_model:
                history[l] = self.read_list(filename)
            else:
                if (l=='memory_history' and save_memory):
                    history[l] = self.read_list(filename)
                else:
                    if(os.path.isfile(filename)):
                        os.remove(filename)
        return history

    # função para atualizar dados no arquivo
    def set_history_list(self,algorithm,history):
        for l in history:
            filename = f'{algorithm}/{l}.dat'
            self.write_list(filename,history[l])