from main import DQN
from env import Perseguidor

import numpy as np
import time

# classe de treinamento
class Train:

    # inicio
    def __init__(self, load_model, save_memory=False, playing=False):
        self.env = Perseguidor() # carrega classe ambiente do perseguidor
        self.load_model = load_model # variavel se é para criar novo modelo ou carregar existente
        self.playing = playing # variavel se é para treinar ou jogar
        self.agent = DQN(self.env,load_model, save_memory) # variavel para carregar/criar modelo DQN
     
    # funcção de treinamento
    def start(self, episodes=1000):
        try:
            # iniciar server socket e o jogo
            self.env.start()
            # esperar 2 segundos
            time.sleep(2)
            
            # pecorre a qunatidade de episodios definidos
            for e in range(episodes):
                # reseta ambiente e carrega estado e informações iniciais
                state, info = self.env.reset()
                # reshape do estado
                state = np.reshape(state, (1, self.agent.state_space))
                done, score = False, 0 # define fim de jogo como false e score como 0
                s = 0 # step
                while not done:
                    # estado do game se esta jogando ou na tela de espera
                    gamestate = self.env._get_info()['info']['gamestate']
                    
                    if gamestate==1:
                        # carrega ação do agente inteligente
                        action = self.agent.act(state, self.load_model)
                        # salva ação desse step/episode no historico
                        self.agent.history['action_history'].append(action)

                        # salva estado anterior
                        prev_state = state
                        # executa novo passo no jogo, retornando dados do novo estado e recompensas
                        next_state, reward, done, info = self.env.step(action)
                        # salva estado no historico
                        self.agent.history['obs_history'].append(next_state)
                        # salva recompensa no historico
                        self.agent.history['reward_history'].append(reward)
                        # soma score do passo 
                        score += reward

                        # reshape do proximo estado
                        next_state = np.reshape(next_state, (1, self.agent.state_space))
                        # salva na memoria
                        self.agent.remember(state, action, reward, next_state, done)
                        # proximo estado
                        state = next_state
                        
                        print("Episode==>{}, Step==>{}, Reward==>{}, Action ==> {}, State == {}".format(e,s, reward, action,0))
                        # se não for para jogar então realizar treinamento
                        if not self.playing:
                            if self.agent.batch_size > 1:
                                self.agent.replay()

                        # se fim de jogo
                        if done:
                            print(f'final state before dying: {str(prev_state)}')
                            print(f'episode: {e+1}/{e}, score: {score}')
                            # salvar historico de segundo maximo
                            self.agent.history['seconds_history'].append(info['player']['seconds'])
                            # salvar historico de score maximo
                            self.agent.history['score_history'].append(info['player']['score'])
                            # renicia o jogo
                            self.env._restart_game()
                            break
                        s += 1
                    else:
                        # caso o jogo esta em tela de espera enviar solicitação e iniciar o jogo
                        while (gamestate!=1):
                            gamestate = self.env._get_info()['info']['gamestate']

                # salvar no historico recompensa maxima do episodio
                self.agent.history['ep_reward'].append(score)

                # salvar no historico da media de recompensa maxima do episodio
                avg_reward = np.mean(self.agent.history['ep_reward'][-40:])
                print("Episode * {} * Avg Reward is ==> {}".format(e, avg_reward))
                self.agent.history['avg_reward'].append(avg_reward)
        finally:
            # fechar server socket e jogo
            self.env.stop()

            # salvar modelo
            self.agent.model.save('dqn/perseguidor.keras')
            #self.agent.model.save_weights('dqn/perseguidor.h5')
            
            # salvar historicos
            self.agent.set_history_list('dqn',self.agent.history)