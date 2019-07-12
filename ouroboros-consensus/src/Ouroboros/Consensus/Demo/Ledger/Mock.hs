{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies          #-}
{-# LANGUAGE UndecidableInstances  #-}

{-# OPTIONS_GHC -fno-warn-orphans #-}

module Ouroboros.Consensus.Demo.Ledger.Mock () where

import           Codec.Serialise (Serialise)
import qualified Codec.Serialise as Serialise
import           Data.Typeable (Typeable)

import           Cardano.Crypto.Hash

import           Ouroboros.Consensus.Block
import           Ouroboros.Consensus.Demo.Run
import           Ouroboros.Consensus.Ledger.Abstract
import           Ouroboros.Consensus.Ledger.Mock
import           Ouroboros.Consensus.Protocol.Abstract (ChainState)
import           Ouroboros.Consensus.Util.Condense

{-------------------------------------------------------------------------------
  RunDemo instance for the mock ledger
-------------------------------------------------------------------------------}

instance HashAlgorithm h => DemoHeaderHash (Hash h a) where
  demoEncodeHeaderHash = Serialise.encode
  demoDecodeHeaderHash = Serialise.decode

instance ( ProtocolLedgerView (SimpleBlock SimpleMockCrypto ext)
           -- The below constraint seems redundant but is not! When removed,
           -- some of the tests loop, but only when compiled with @-O2@ ; with
           -- @-O0@ it is perfectly fine. ghc bug?!
         , SupportedBlock (SimpleBlock SimpleMockCrypto ext)
         , Condense ext
         , Show ext
         , Typeable ext
         , Serialise ext
         , ForgeExt (BlockProtocol (SimpleBlock SimpleMockCrypto ext))
                    SimpleMockCrypto
                    ext
         , Serialise (ChainState (BlockProtocol (SimpleBlock SimpleMockCrypto ext)))
         ) => RunDemo (SimpleBlock  SimpleMockCrypto ext) where
  demoForgeBlock         = forgeSimple
  demoBlockMatchesHeader = matchesSimpleHeader
  demoBlockFetchSize     = fromIntegral . simpleBlockSize . simpleHeaderStd
  demoIsEBB              = const False
  demoEpochSize          = \_ _ -> return 21600
  demoEncodeBlock        = const Serialise.encode
  demoEncodeHeader       = const Serialise.encode
  demoEncodeGenTx        =       Serialise.encode
  demoEncodeLedgerState  = const Serialise.encode
  demoEncodeChainState   = const Serialise.encode
  demoDecodeBlock        = const Serialise.decode
  demoDecodeHeader       = const Serialise.decode
  demoDecodeGenTx        =       Serialise.decode
  demoDecodeLedgerState  = const Serialise.decode
  demoDecodeChainState   = const Serialise.decode
  demoMockTx             = \_ -> SimpleGenTx