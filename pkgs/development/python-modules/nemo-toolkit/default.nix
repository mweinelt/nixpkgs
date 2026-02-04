{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
  fetchurl,

  # build-system
  setuptools,

  # dependencies
  fsspec,
  huggingface-hub,
  numba,
  cuda-bindings,
  numexpr,
  numpy,
  onnx,
  protobuf,
  python-dateutil,
  ruamel-yaml,
  scikit-learn,
  tensorboard,
  text-unidecode,
  torch,
  tqdm,
  wget,
  wrapt,

  # optional-dependencies
  addict,
  attrdict,
  boto3,
  braceexpand,
  clip,
  cloudpickle,
  datasets,
  diffusers,
  diskcache,
  editdistance,
  einops,
  faiss,
  flask-restful,
  ftfy,
  gdown,
  h5py,
  hydra-core,
  ijson,
  imageio,
  inflect,
  jieba,
  jiwer,
  kornia,
  librosa,
  lightning,
  markdown2,
  marshmallow,
  matplotlib,
  mediapy,
  nltk,
  omegaconf,
  opencc,
  open-clip-torch,
  optuna,
  packaging,
  pandas,
  peft,
  pesq,
  prettytable,
  progress,
  pyannote-core,
  pyannote-metrics,
  pydub,
  pyopenjtalk,
  pypinyin,
  rapidfuzz,
  resampy,
  rouge-score,
  sacrebleu,
  sacremoses,
  scipy,
  seaborn,
  sentencepiece,
  sentence-transformers,
  soundfile,
  sox,
  tabulate,
  tensorstore,
  textdistance,
  tiktoken,
  torchdiffeq,
  torchmetrics,
  torchsde,
  transformers,
  trimesh,
  wandb,
  webdataset,
  zarr,

  # tests
  pytest-httpserver,
  pytest-mock,
  pytestCheckHook,
}:

let
  test_data = fetchurl {
    url = "https://github.com/NVIDIA/NeMo/releases/download/v1.0.0rc1/test_data.tar.gz";
    hash = "sha256-vK80aVPdt9vXPGeSUjCIZUbP6nEg/auLGZ+TjtWWDF0=";
  };
in

buildPythonPackage (finalAttrs: {
  pname = "nemo-toolkit";
  version = "2.6.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "NVIDIA-NeMo";
    repo = "NeMo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-EsdslkbFKs4QDc2muFGqnJ1IKglbpBQ6vq0GgYxl+HY=";
  };

  build-system = [
    setuptools
  ];

  pythonRemoveDeps = [
    # implicit
    "numba-cuda"

    # older version pins
    "fsspec"
    "numexpr"
    "protobuf"
  ];

  dependencies = [
    # https://github.com/NVIDIA-NeMo/NeMo/blob/main/requirements/requirements.txt
    fsspec
    huggingface-hub
    numba
    numexpr
    numpy
    onnx
    protobuf
    python-dateutil
    ruamel-yaml
    scikit-learn
    tensorboard
    text-unidecode
    torch
    tqdm
    wget
    wrapt
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    cuda-bindings
  ];

  optional-dependencies = lib.fix (self: {
    asr = self.asr-only;
    asr-only = [
      braceexpand
      diskcache
      editdistance
      einops
      jiwer
      # TODO: kaldi-python-io
      # TODO: kaldialign
      # TODO: lhotse
      librosa
      marshmallow
      optuna
      packaging
      pyannote-core
      pyannote-metrics
      pydub
      # TODO: pyloudnorm
      resampy
      ruamel-yaml
      sacrebleu
      scipy
      soundfile
      sox
      # TODO: whisper-normalizer
    ];
    audio = [
      einops
      # TODO: lhotse
      librosa
      matplotlib
      # TODO: pystoi
      scipy
      soundfile
    ]
    ++ lib.optionals (!stdenv.hostPlatform.isDarwin && !stdenv.hostPlatform.isx86_64) [
      pesq
    ];
    common = with self; common-only ++ core;
    common-only = [
      datasets
      einops
      inflect
      mediapy
      pandas
      sacremoses
      sentencepiece
    ];
    core = self.lightning;
    lightning= [
      cloudpickle
      # TODO: fiddle
      hydra-core
      lightning
      omegaconf
      peft
      torchmetrics
      transformers
      wandb
      webdataset
      # TODO: nv-one-logger
      # TODO: nv-one-logger-training-telemetry
      # TODO: nv-one-logger-pytorch-lightning-integration
    ];
    multimodal-only = [
      addict
      clip
      diffusers
      # TODO: einops_exts
      imageio
      kornia
      # TODO: megatron-energon
      # TODO: nerfacc
      open-clip-torch
      # TODO: qwen-vl-utils
      # TODO: taming-transformers
      torchdiffeq
      torchsde
      trimesh
    ]
    ++ lib.optionals (stdenv.hostPlatform.isx86_64 && stdenv.hostPlatform.isLinux) [
      # TODO: decord
    ];
    nlp-only = [
      # TODO: accelerated-scan
      boto3
      faiss
      flask-restful
      ftfy
      gdown
      h5py
      ijson
      jieba
      markdown2
      matplotlib
      # TODO: megatron-core
      # TODO: multi-storage-client
      nltk
      numpy
      # TODO: nvidia-modelopt
      # TODO: nvidia-resiliency-ext
      # TODO: nvtx
      opencc
      # TODO: pangu
      prettytable
      rapidfuzz
      rouge-score
      sacrebleu
      sentence-transformers
      tensorstore
      tiktoken
      zarr
    ];
    slu = [
      jiwer
      progress
      tabulate
      textdistance
      tqdm
    ];
    tts = [
      attrdict
      # TODO: cdifflib
      einops
      # TODO: janome
      jieba
      kornia
      librosa
      matplotlib
      nltk
      pandas
      pypinyin
      # TODO: pypinyin-dict
      seaborn
      pyopenjtalk
    ]
    ++ lib.optionals (!stdenv.hostPlatform.isAarch64 && !stdenv.hostPlatform.isDarwin) [
      # pynini does not currently support aarch, disable nemo_text_processing for now
      # TODO: nemo-text-processing
    ];
  });

  nativeCheckInputs = [
    pytest-httpserver
    pytest-mock
    pytestCheckHook
  ]
  ++ finalAttrs.passthru.optional-dependencies.common
  ++ finalAttrs.passthru.optional-dependencies.tts;

  preCheck = ''
    mkdir -p tests/.data
    ln -s ${test_data} tests/.data/test_data.tar.gz
  '';

  pythonImportsCheck = [
    "nemo"
  ];

  meta = {
    description = "Scalable generative AI framework built for researchers and developers working on Large Language Models, Multimodal, and Speech AI";
    homepage = "https://github.com/NVIDIA-NeMo/NeMo";
    changelog = "https://github.com/NVIDIA-NeMo/NeMo/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
