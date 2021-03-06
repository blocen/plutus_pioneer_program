{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE DataKinds        #-}

module Week04.Trace where

import Control.Monad.Freer.Extras as Extras
import Data.Default               (Default (..))
import Data.Functor               (void)
import Ledger.TimeSlot
import Plutus.Trace
import Wallet.Emulator.Wallet

import Week04.Vesting

-- Contract w s e a
-- EmulatorTrace a

test :: IO ()
test = runEmulatorTraceIO myTrace

myTrace :: EmulatorTrace ()
myTrace = do
    contractHandle1 <- activateContractWallet (knownWallet 1) endpoints
    contractHandle2 <- activateContractWallet (knownWallet 2) endpoints
    callEndpoint @"give" contractHandle1 $ GiveParams
        { gpBeneficiary = mockWalletPaymentPubKeyHash $ knownWallet 2
        , gpDeadline    = slotToBeginPOSIXTime def 20
        , gpAmount      = 10000000
        }
    -- void $ waitUntilSlot 20
    void $ waitUntilSlot 10
    callEndpoint @"grab" contractHandle2 ()
    s <- waitNSlots 2
    Extras.logInfo $ "reached " ++ show s
