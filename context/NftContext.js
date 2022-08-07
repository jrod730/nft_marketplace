import React, { useState, useEffect } from 'react';
import Web3Modal from 'web3modal';
import { etheres } from 'ethers';
import axios from 'axios';

import { MarketAddress, MarketAddressAbi } from './constants';

export const NftContext = React.createContext();

export const NftProvider = ({ children }) => {
  const nftCurrency = 'ETH';
  const [currentAccount, setCurrentAccount] = useState('');

  const checkIfWalletIsConnected = async () => {
    if (!window.ethereum) {
      return alert('Please install MetaMask.');
    }

    const accounts = await window.ethereum.request({ method: 'eth_accounts' });

    console.log({ accounts });
  };

  useEffect(() => checkIfWalletIsConnected(), []);

  const connectWallet = async () => {
    if (!window.ethereum) {
      return alert('Please install MetaMask.');
    }
    const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });

    setCurrentAccount(accounts[0]);
    window.location.reload();
  };

  return (
    <NftContext.Provider value={{ nftCurrency, currentAccount }}>
      {children}
    </NftContext.Provider>
  );
};
