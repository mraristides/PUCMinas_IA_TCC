import numpy as np
import socket
import json
import time
import subprocess
import os

# Importando Address do socket UDP
UDP_IP = "0.0.0.0"
UDP_PORT = 2223
addrinfo = socket.getaddrinfo(
  UDP_IP, UDP_PORT,
  socket.AF_INET, socket.SOCK_DGRAM)[0]

# Criação do ambiente 
class Perseguidor():

    def __init__(self):
        self.state_space = np.array(np.zeros(24)) # vetor de estados
        self.action_space = np.array(np.zeros(4)) # vetor de ações
        self.width = 41 # largura do cenario
        self.height = 19 # altura  do cenario
        self.max_distance = 43 # distancia maxima entre os objetos ( player, inimigo e moedas )

        
    # carrega observações do ambiente
    def _get_states(self):
        # carrega dados recebidas do servidor
        info = self._get_info()

        self._coins = info['coins'][0]['direction'] # vetor de direção da moeda
        self._danger = info['player']['dangers'] # vetor de direção do perigo
        self._walls = info['player']['walls'] # vetor de direção da colisao com a parede
        self._direction = info['player']['direction'] # vetor de direção atual do player

        self._persons = np.array([
            info['player']['x'], # player x
            info['player']['y'], # player y
            info['enemy']['x'], # enemy x
            info['enemy']['y'], # enemy y
            info['coins'][0]['x'], # coin x
            info['coins'][0]['y'], # coin y
            info['player']['distance'], # distance player from enemy
            info['coins'][0]['distance'], # distance payer from coin
        ])

        # concatenando os vetores em um unico vetor 
        states = np.concatenate([self._direction, self._walls, self._danger, self._coins, self._persons  ]) 
        # retorno
        return states, info
    
    # carrega dados do servidor
    def _get_info(self):
        with socket.socket(*addrinfo[:3]) as sock:
            sock.connect(addrinfo[4])
            # pecorre ate receber socket do servidor
            while True:
                # envio de socket para servidor
                sock.sendto(str.encode(''), (UDP_IP, UDP_PORT))
                # define dados recebidos
                data, addr = sock.recvfrom(1024)
                # se existir dados
                if data:
                    # conversao de json para python
                    res = json.loads(data)
                    sock.close()
                    # retorno
                    return res['game']
    
    # recarrega dados do servidor e informaçõs do ambiente
    def reset(self): 
        #define observação do ambiente e dados do servidor
        obs, info = self._get_states() 
        # retorno
        return obs, info
    
    def _restart_game(self):
        # define json de reset do jogo
        agent_step = str.encode(json.dumps({'action': -1,'restart': True, 'socket': 'agent'}))
        # envia json
        with socket.socket(*addrinfo[:3]) as sock:
            sock.connect(addrinfo[4])
            sock.sendto(agent_step, (UDP_IP, UDP_PORT))
            sock.close()


    # envia para o servidor socket ação recebida e carrega observações do ambiente recente
    def step(self, action):
        # conversão da ação recebida para enviar no servidor socket
        agent_step = str.encode(json.dumps({'action': int(action),'restart': False, 'socket': 'agent'}))
        # envia para servidor socket a ação recebida e preditada.
        with socket.socket(*addrinfo[:3]) as sock:
            sock.connect(addrinfo[4])
            sock.sendto(agent_step, (UDP_IP, UDP_PORT))
            sock.close()
        #define observação do ambiente e dados do servidor
        obs, info = self._get_states()
        done, reward = info['player']['done'], info['player']['reward']
        # retorno
        return obs, reward, done, info
    
    # função destinada para iniciar o server socket e o jogo
    def start(self):
        # iniciar processo do servidor socket
        server = subprocess.Popen(['node ~/posgraduacao/tcc/projeto/server/index.js'], shell=True)
        # aguardar 1 segundo
        time.sleep(1)
        # iniciar processo do jogo
        game = subprocess.Popen(['love ~/posgraduacao/tcc/projeto/game'], shell=True)

    # função destinada para parar o server socket e o jogo
    def stop(self):
        try:
            # check se existe o processo do jogo
            pid = list(map(int,subprocess.check_output(["pidof",'love']).split()))[0]
            # condição de existe
            if pid != 0:
                # encerra o processo do jogo.
                os.system('kill '+str(pid))
        except:
            pid = 0
            
        # aguardar 1 segundo
        time.sleep(1)
        try:
            # check se existe o processo do servidor socket
            pid = list(map(int,subprocess.check_output(["pidof",'node']).split()))[0]
            # condição de existe
            if pid != 0:
                # encerra o processo do servidor socket
                os.system('kill '+str(pid))
        except:
            pid = 0
  