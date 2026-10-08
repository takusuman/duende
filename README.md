# duende
Experiment on parsing ``Elf{32,64}_Ehdr`` on (almost) pure shell.

## How?

When we view binary files as a amalgam of data sectionated per its sizes and
that can be received according to its respective types, it becomes quite clear
that it's just a matter of reading byte-per-byte and, let's say, "reconverting"
back to the form it was intended to be used --- be that ASCII representation,
integers or even just another container of data (ex.: zip files) --- therefore,
it isn't surreal to think on reading this data and working with it inside any
programming language; there are limits depending on what one would want to do,
of course.  
In this case, it's just poking an extremely documented type of binary file, ELF,
and reading certain numbers and chain of characters that might be of our
interest for obtaining certain information.  
It's __almost__ pure shell because, since this proof-of-concept is being written
in pure POSIX, the ``read`` builtin doesn't support reading byte-per-byte, so
we're forced to use ``od``(1) here for both reading and "converting" the data to
the necessary format.

## Why?

It all started in the last Sunday's early hours, when, after compiling a handful
of packages over the
[Copacabana 0.4 Docker Image](https://hub.docker.com/r/takusuman/copadocker)
so it'd be able to run the
[new build system](https://github.com/Projeto-Pindorama/copacabana/tree/copaclang/build-system),
and then ran into a problem when doas, used by the ``check_elevate_method()``
function, even though linked to OpenPAM on compile time, was not finding the
``.so`` libraries at ``/usr/local/lib``. So I went and ran ``ldconfig``(8) just
to discover that, as to be expected from a half-backed compilation (a.k.a.
"Developer Release"), it didn't work properly because ``scanelf`` wasn't
installed:

<a href="https://twitter.com/the_takusuman/status/2106625460327383545">
<img width="420" height="545" alt="output"
  src="https://github.com/user-attachments/assets/8b4b99c3-5895-454f-951e-2c8cf36d8b98"/></a>

Then I went and hacked the ``ldconfig``(8) script, originally made by Samuel
Holland (@smaeul), to not depend exclusively on ``scanelf`` anymore, though it
now depended on GNU Binutils' ``objdump``(1) from ``/usr/ccs/bin``, which is far
from optimal on a production environment. I've initially theorized about the
possibility of using ``dd``(1) for reading the binary and then, by some way,
work with the data; of course, it didn't seem to work, it just printed
apparently meaningless symbols and I wasn't thinking much on making it depend on
[``hd``(1XNX)](https://heirloom-ng.pindorama.net.br/manual/man1/hd.1.html),
until I've researched a little bit more and actually learnt about ``od``(1)'s
capacibilities, which resulted in this. [It can even seek on the
disk!](https://heirloom-ng.pindorama.net.br/manual/man1/od.1.html#j)  

## Who cares?

This is actually (somewhat) useful in the context of Copacabana.  
And yes, I believe it can be useful for more people.  
Of course, in an era of AI here, AI there, AI in your parents' bathroom sink
cabinet, I don't expect this to bring a lot of attention...
But it is quite cool, eh?

## Why is the code so ugly?

This is POSIX shell. What did you expect?  
We're not actually doing it, we're managing to do it. There's a difference,
y'know.  
It could be worse, it could be pure Bourne shell.

## How's the speed?

Obviously slower than using Binutils' ``objdump``, PaX Utils' ``scanelf`` or
anything like, and most certainly it also has more disk accesses in comparison
since we're not buffering anything. There's room for improvement in these
aspects.  
But, in general, it will be slower, and it's fine for the purposes of being used
pontually.

## Who can I blame for it?

I, who speak to you, Luiz Antônio (a.k.a. takusuman).

## How can I share it?

This code is under the MIT license, use it as you will.  
In fact, if you've learnt it from here and made a clean-room implementation,
I've just would like a citation. :^)  
For Copacabana's ``ldconfig``(8) script, maybe I will just fork Holland's work
and relicence it under MIT for it to match this (or the reverse).
