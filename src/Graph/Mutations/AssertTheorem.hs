{-# LANGUAGE DeriveGeneric #-}
module Graph.Mutations.AssertTheorem
  ( AssertTheoremInput
  , assertTheorem
  ) where

import qualified Import
import           Graph.Import
import           Data.Aeson     (decode)
import qualified Data.Text.Lazy as TL

import           Core        (SpaceId(..), PropertyId(..), Formula(..))
import qualified Data        as D
import qualified Graph.Types as G
import qualified Graph.Query as G

data AssertTheoremInput = AssertTheoremInput
  { antecedent  :: Text
  , consequent  :: Text
  , description :: Text
  } deriving (Show, Generic)

instance FromValue AssertTheoremInput
instance HasAnnotatedInputType AssertTheoremInput
instance Defaultable AssertTheoremInput where
  defaultFor _ = error "No default for AssertTheoremInput"

assertTheorem :: AssertTheoremInput -> G G.Viewer
assertTheorem i@AssertTheoremInput{..} = do
  (Entity _ user) <- requireToken
  a <- parseFormula antecedent
  c <- parseFormula consequent
  updates <- D.assertTheorem user a c description
  case updates of
    Left err -> error $ show err
    Right view -> G.viewR view

parseFormula :: Text -> Import.Handler (Formula PropertyId)
parseFormula text = case decode $ encodeUtf8 $ TL.fromStrict text of
    Nothing -> halt $ "Could not parse formula: " <> show text
    Just f  -> return $ PropertyId <$> f