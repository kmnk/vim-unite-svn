# vim-unite-svn

一部のsvnコマンドを実行して結果を表示するunite-sourceです。
基本的には status を開いて、選択して何かするというフローを簡易化することを目的としています。
付加として、 diff や blame の結果を見て、対象行にjump出来るようにしています。


## Usage

### Install

    NeoBundle 'git://github.com/kmnk/vim-unite-svn.git'


### Command

sourceとしては status, diff, blame のみ用意しています。

    Unite svn/status
    Unite svn/diff
    Unite svn/blame

#### status

status で表示されたファイルを選択した後のコマンドとしては以下を用意しています。

- commit
- add
- revert
- blame
- delete
- log
- diff
- resolved

diff, blame は source を実行したときと同様の動作をします。

deleteは今動かないです。

logとblameは複数選択できません


#### diff

未コミットの編集状態と最後にupdateしたものとのdiffを表示します。


#### blame

現在開いているファイルのblame結果を表示します


## TODO

- 頑張る
- infoの実装
- インターフェースとかUIをもっときれいにする
- ドキュメントの整備
- gitに浮気する
